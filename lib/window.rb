#
# Copyright (c) 2014 Christopher Aue <mail@christopheraue.net>
#
# This file is part of the ruby xlib-objects gem. It is subject to the license
# terms in the LICENSE file found in the top-level directory of this
# distribution and at http://github.com/christopheraue/ruby-xlib-objects.
#

module XlibObj
  class Window
    def initialize(display, window_id)
      @display = display
      @to_native = window_id
      @event_handler = EventHandler.singleton(display, self)
    end

    # Queries
    attr_reader :display, :to_native
    alias_method :id, :to_native

    def attribute(name)
      attributes = Xlib::WindowAttributes.new
      Xlib.XGetWindowAttributes(@display.to_native, @to_native, attributes.pointer)
      attributes[name.to_sym]
    rescue
      nil
    end

    def method_missing(name)
      attribute(name)
    end

    def screen
      Screen.new(@display, attribute(:screen))
    end

    def property(name)
      Property.new(self, name).get
    end

    def absolute_position
      x_abs = FFI::MemoryPointer.new :int
      y_abs = FFI::MemoryPointer.new :int
      child = FFI::MemoryPointer.new :Window
      root_win = screen.root_window

      Xlib.XTranslateCoordinates(@display.to_native, @to_native, root_win.to_native, 0, 0, x_abs,
        y_abs, child)

      { x: x_abs.read_int, y: y_abs.read_int }
    end

    def focused?
      focused_window = FFI::MemoryPointer.new :Window
      focus_state = FFI::MemoryPointer.new :int
      Xlib.XGetInputFocus(@display.to_native, focused_window, focus_state)
      focused_window.read_int == @to_native
    end

    # Commands
    def set_property(name, value)
      Property.new(self, name).set(value)
    end

    def delete_property(name)
      Property.new(self, name).delete
    end

    def move_resize(x, y, width, height)
      Xlib.XMoveResizeWindow(@display.to_native, @to_native, x, y, width, height)
      @display.flush
      self
    end

    def map
      Xlib.XMapWindow(@display.to_native, @to_native)
      @display.flush
      self
    end

    def unmap
      Xlib.XUnmapWindow(@display.to_native, @to_native)
      @display.flush
      self
    end

    def iconify
      Xlib.XIconifyWindow(@display.to_native, @to_native, screen.number)
      @display.flush
      self
    end

    def raise
      Xlib.XRaiseWindow(@display.to_native, @to_native)
      @display.flush
      self
    end

    def focus
      Xlib.XSetInputFocus(@display.to_native, @to_native, Xlib::RevertToParent, Xlib::CurrentTime)
      @display.flush
      self
    end

    def on(mask, type, &callback)
      @event_handler.on(mask, type, &callback)
    end

    def until_true(mask, type, &callback)
      handler = on(mask, type) do |*args|
        off(mask, type, handler) if callback.call(*args)
      end
    end

    def off(mask, type, callback = nil)
      @event_handler.off(mask, type, callback)
      self
    end

    def handle(event)
      @event_handler.handle(event)
      self
    end

    def send_to_itself(type, data = nil, subject = nil)
      Event::ClientMessage.new(type, data, subject).send_to(self)
      self
    end

    def request_selection(type = :PRIMARY, target: :UTF8_STRING, property: :XSEL_DATA, &on_receive)
      # will only receive the selection notify event, if the window has been created by the process
      # running this very code
      until_true(:no_event, :selection_notify) do |event|
        break false if Atom.new(@display, event.selection).name != type
        break false if Atom.new(@display, event.target).name != target

        # query selection content
        if event.property == Xlib::None
          selection = nil
        else
          selection = property(event.property)
          delete_property(event.property)
        end

        # send selection to callback
        selection_owner = Window.new(@display, Xlib.XGetSelectionOwner(@display.to_native, event.selection))
        on_receive.call(selection, type, selection_owner)

        true
      end

      # request the selection
      type_atom = Atom.new(@display, type)
      target_atom = Atom.new(@display, target)
      property_atom = Atom.new(@display, property)
      Xlib.XConvertSelection(@display.to_native, type_atom.to_native, target_atom.to_native,
        property_atom.to_native, @to_native, Xlib::CurrentTime)
      @display.flush

      self
    end

    def set_selection(type = :PRIMARY, targets: [:UTF8_STRING, :STRING, :TEXT], &on_request)
      type_atom = Atom.new(@display, type)
      Xlib.XSetSelectionOwner(@display.to_native, type_atom.to_native, to_native, Xlib::CurrentTime)

      request_handler = on(:no_event, :selection_request) do |event|
        break if Atom.new(@display, event.selection).name != type

        # convert selection
        target = Atom.new(@display, event.target).name
        selection = if target == :TARGETS
                      (targets + [:TARGETS]).map{ |t| Atom.new(@display, t) }
                    elsif targets.include? target
                      on_request.call(target)
                    end

        # set property on requestor
        requestor = Window.new(@display, event.requestor)
        if selection
          property = event.property == Xlib::None ? event.target : event.property
          requestor.set_property(property, selection)

          # notify requestor of set property
          Event::SelectionNotify.new(type: event.selection, target: event.target, property: property).
            send_to(requestor)
        else
          # notify requestor of failed conversion
          Event::SelectionNotify.new(type: event.selection, target: event.target, property: Xlib::None).
            send_to(requestor)
        end
      end

      until_true(:no_event, :selection_clear) do |event|
        break false if Atom.new(@display, event.selection).name != type
        off(:no_event, :selection_request, request_handler)
        true
      end

      self
    end

    def create_window
      black = Xlib.XBlackPixel(@display.to_native, 0)
      win_id = Xlib.XCreateSimpleWindow(@display.to_native, to_native, 0, 0, 1, 1, 0, black, black)
      Window.new(@display, win_id)
    end

    def create_input_window
      attributes = Xlib::SetWindowAttributes.new
      win_id = Xlib.XCreateWindow(@display.to_native, to_native, 0, 0, 1, 1, 0, Xlib::CopyFromParent,
        Xlib::InputOnly, nil, 0, attributes.pointer)
      Window.new(@display, win_id)
    end

    def destroy
      @event_handler.destroy
      Xlib.XDestroyWindow(@display.to_native, to_native)
    end
  end
end