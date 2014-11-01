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

    def content_left
      content_position.left
    end

    def content_top
      content_position.top
    end

    def content_position
      relative_to_root(0, 0)
    end

    def content_width
      content_size.width
    end

    def content_height
      content_size.height
    end

    def content_size
      attr = attributes
      Struct.new(width: attr[:width], height: attr[:height])
    end

    def frame
      frame = property(:_NET_FRAME_EXTENTS)
      Struct.new(left: frame[0], top: frame[2], right: frame[1],
        bottom: frame[4])
    end

    def position
      content_position = self.content_position
      frame = self.frame
      Struct.new(
        left: content_position.left - frame.left,
        top:  content_position.top  - frame.top
      )
    end

    def left
      position.left
    end

    def top
      position.top
    end

    def size
      content_size = self.content_size
      frame = self.frame
      Struct.new(
        width:  content_size.width  - frame.width,
        height: content_size.height - frame.height
      )
    end

    def width
      position.width
    end

    def height
      position.height
    end

    def map
      X11::Xlib.XMapWindow(display.to_native, to_native)
      display.flush
    end

    def unmap
      X11::Xlib.XUnmapWindow(display.to_native, to_native)
      display.flush
    end

    def minimize
      X11::Xlib.XIconifyWindow(display.to_native, to_native, screen.number)
      display.flush
    end

    def iconify
      minimize
    end

    def unminimize
      map
    end

    def deiconify
      unminimize
    end

    def raise
      X11::Xlib.XRaiseWindow(display.to_native, to_native)
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
      begin
        X11::Xlib.XSelectInput(display.to_native, to_native, @event_mask)
      rescue
        # rescue from BadWindow errors, it the window has been destroyed
        raise "The window with id '#{to_native}' no longer exists."
      end
      display.flush
      self
    end

    def turn_deaf_on(event_mask)
      raise "Unknown event #{event_mask}." unless X11::Xlib::EVENT_MASK[event_mask]

      @event_mask &= ~X11::Xlib::EVENT_MASK[event_mask]
      # rescue from BadWindow errors, it the window has been destroyed. Ignore
      # it, since there won't be any events any more anyway
      X11::Xlib.XSelectInput(display.to_native, to_native, @event_mask) rescue
      display.flush
      self
    end

    def on(event_name, &block)
      raise "Unknown event #{event_name}." unless X11::Xlib::EVENT[event_name]

      @event_handler[X11::Xlib::EVENT[event_name]] = block
      self
    end

    def off(event_name)
      raise "Unknown event #{event_name}." unless X11::Xlib::EVENT[event_name]

      @event_handler[X11::Xlib::EVENT[event_name]] = nil
      self
    end

    def handle(event)
      if event.respond_to? :x and event.respond_to? :y
        pos_abs = relative_to_root(0, 0)
        frame = self.frame
        event.struct[:x] = pos_abs.left - frame.left
        event.struct[:y] = pos_abs.top  - frame.top
      end
      @event_handler[event.type].call(event) if @event_handler[event.type]
    end

    private
    def attributes
      attributes = X11::Xlib::WindowAttributes.new
      X11::Xlib::XGetWindowAttributes(display.to_native, to_native, attributes.pointer)
      attributes
    end

    def relative_to_root(left, top)
      left_abs = FFI::MemoryPointer.new :int
      top_abs  = FFI::MemoryPointer.new :int
      child    = FFI::MemoryPointer.new :Window
      root_win = screen.root_window

      X11::Xlib::XTranslateCoordinates(display.to_native, to_native,
        root_win.to_native, left, top, left_abs, top_abs, child)

      Struct.new(left: left_abs.read_int, top: top_abs.read_int)
    end
  end
end