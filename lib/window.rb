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
      @event_handler = EventHandler.singleton(display, window_id)
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

    def set_property(name, value)
      Property.new(self, name).set(value)
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

    # Commands
    def move_resize(x, y, width, height)
      Xlib.XMoveResizeWindow(@display.to_native, @to_native, x, y, width, height)
      Xlib.XFlush(@display.to_native)
      self
    end

    def map
      Xlib.XMapWindow(@display.to_native, @to_native)
      Xlib.XFlush(@display.to_native)
      self
    end

    def unmap
      Xlib.XUnmapWindow(@display.to_native, @to_native)
      Xlib.XFlush(@display.to_native)
      self
    end

    def iconify
      Xlib.XIconifyWindow(@display.to_native, @to_native, screen.number)
      Xlib.XFlush(@display.to_native)
      self
    end

    def raise
      Xlib.XRaiseWindow(@display.to_native, @to_native)
      Xlib.XFlush(@display.to_native)
      self
    end

    def focus
      Xlib.XSetInputFocus(@display.to_native, @to_native, Xlib::RevertToParent, Xlib::CurrentTime)
      Xlib.XFlush(@display.to_native)
      self
    end

    def on(mask, type, &callback)
      @event_handler.on(mask, type, &callback)
    end

    def off(mask, type, callback)
      @event_handler.off(mask, type, callback)
      self
    end

    def handle(event)
      @event_handler.handle(event)
      self
    end

    def send_to_itself(type, data = nil, subject = nil)
      Event::ClientMessage.new(type, data, subject).send_to(self)
    end
  end
end