module CappXlib
  class Window
    attr_reader :display, :to_native

    def initialize(display, window_id)
      @display = display
      @to_native = window_id
      @event_handler = EventHandler.new(self)
    end

    # Queries
    alias_method :id, :to_native

    def attribute(name)
      attributes = Xlib::WindowAttributes.new
      Xlib.XGetWindowAttributes(display.to_native, to_native, attributes.
        pointer)
      attributes[name.to_sym]
    end

    def method_missing(name)
      attribute(name)
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
      root_win = display.screen.root_window

      Xlib.XTranslateCoordinates(display.to_native, window.to_native,
        root_win.to_native, 0, 0, x_abs, y_abs, child)

      { x: x_abs.read_int, y: y_abs.read_int }
    end

    # Commands
    def move_resize(x, y, width, height)
      Xlib.XMoveResizeWindow(display.to_native, to_native, x, y, width,
        height)
      Xlib.XFlush(display.to_native)
      self
    end

    def map
      Xlib.XMapWindow(display.to_native, to_native)
      Xlib.XFlush(display.to_native)
      self
    end

    def unmap
      Xlib.XUnmapWindow(display.to_native, to_native)
      Xlib.XFlush(display.to_native)
      self
    end

    def iconify
      Xlib.XIconifyWindow(display.to_native, to_native, screen.number)
      Xlib.XFlush(display.to_native)
      self
    end

    def raise
      Xlib.XRaiseWindow(display.to_native, to_native)
      Xlib.XFlush(display.to_native)
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
  end
end