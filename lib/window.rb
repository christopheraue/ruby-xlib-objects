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

    attr_reader :display

    def initialize(display, window_id)
      @display = display
      @native = window_id
      @event_mask = 0
      @event_handler = {}
    end

    def to_native
      @native
    end

    def left
      attributes[:x]
    end

    def top
      attributes[:y]
    end

    def width
      attributes[:width]
    end

    def height
      attributes[:height]
    end

    def map
      X11::Xlib.XMapWindow(display.to_native, to_native)
      display.flush
    end

    def unmap
      X11::Xlib.XUnmapWindow(display.to_native, to_native)
      display.flush
    end

    def map_state
      X11::Xlib::MAP_STATE[attributes[:map_state]]
    end

    def mapped?
      map_state != 'IsUnmapped'
    end

    def visible?
      map_state == 'IsViewable'
    end

    def move_resize(x, y, width, height)
      X11::Xlib.XMoveResizeWindow(display.to_native, to_native, x, y, width, height)
      display.flush
    end

    def screen
      Screen.new(display, attributes[:screen])
    end

    def property(name)
      Property.get(self, name)
    end

    def properties
      Property.all(self)
    end

    def listen_to(event_mask)
      raise "Unknown event #{event_mask}." unless X11::Xlib::EVENT_MASK[event_mask]

      @event_mask |= X11::Xlib::EVENT_MASK[event_mask]
      X11::Xlib.XSelectInput(display.to_native, to_native, @event_mask)
      display.flush
      self
    end

    def turn_deaf_on(event_mask)
      raise "Unknown event #{event_mask}." unless X11::Xlib::EVENT_MASK[event_mask]

      @event_mask &= ~X11::Xlib::EVENT_MASK[event_mask]
      X11::Xlib.XSelectInput(display.to_native, to_native, @event_mask)
      display.flush
      self
    end

    def on(event_name, &block)
      raise "Unknown event #{event_name}." unless X11::Xlib::EVENT[event_name]

      @event_handler[X11::Xlib::EVENT[event_name]] = block
      self
    end

    def handle(event)
      @event_handler[event.type].call(event) if @event_handler[event.type]
    end

    private
    def attributes
      attributes = X11::Xlib::WindowAttributes.new
      X11::Xlib::XGetWindowAttributes(display.to_native, to_native, attributes.pointer)
      attributes
    end
  end
end