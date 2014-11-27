module CappX11
  class Window
    class << self
      def new(display, window_id, reinitialize = false)
        @windows ||= {}
        @windows[display.name] ||= {}

        if reinitialize
          @windows[display.name][window_id] = super(display, window_id)
        else
          @windows[display.name][window_id] ||= super(display, window_id)
        end
      end
    end

    attr_reader :display, :to_native

    def initialize(display, window_id)
      @display = display
      @to_native = window_id
      @event_handler = CappX11::Window::EventHandler.new(self)
    end

    # Queries
    def attribute(name)
      attributes = X11::Xlib::WindowAttributes.new
      X11::Xlib::XGetWindowAttributes(display.to_native, to_native, attributes.pointer)
      attributes[name.to_sym]
    end

    def property(name)
      Property.get(self, name)
    end

    def set_property(name, value)
      Property.set(self, name, value)
    end

    def absolute_position
      x_abs = FFI::MemoryPointer.new :int
      y_abs = FFI::MemoryPointer.new :int
      child = FFI::MemoryPointer.new :Window
      root_win = display.screen.root_window

      X11::Xlib::XTranslateCoordinates(display.to_native, window.to_native,
        root_win.to_native, 0, 0, x_abs, y_abs, child)

      { x: x_abs.read_int, y: y_abs.read_int }
    end

    # Commands
    def move_resize(x, y, width, height)
      X11::Xlib.XMoveResizeWindow(display.to_native, to_native, x, y, width,
        height)
      display.flush
      self
    end

    def map
      X11::Xlib.XMapWindow(display.to_native, to_native)
      display.flush
      self
    end

    def unmap
      X11::Xlib.XUnmapWindow(display.to_native, to_native)
      display.flush
      self
    end

    def iconify
      X11::Xlib.XIconifyWindow(display.to_native, to_native, screen.number)
      display.flush
      self
    end

    def raise
      X11::Xlib.XRaiseWindow(display.to_native, to_native)
      display.flush
      self
    end

    def on(mask, type, &callback)
      @event_handler.on(mask, type, &callback)
      self
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