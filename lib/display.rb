module CappX11
  class Display
    class << self
      def open(name, reopen = true)
        @displays ||= {}

        if reopen
          @displays[name] = X11::Xlib.XOpenDisplay(name)
        else
          @displays[name] ||= X11::Xlib.XOpenDisplay(name)
        end

        raise ArgumentError, "Unknown display #{name}" if @displays[name].null?

        new(@displays[name])
      end

      def names
        Dir['/tmp/.X11-unix/*'].map do |file_name|
          match = file_name.match(/X(\d+)$/)
          ":#{match[1]}" if match
        end
      end

      def all
        names.map { |name| open(name) }
      end
    end

    def initialize(display_pointer)
      @struct = X11::Xlib::Display.new(display_pointer)
    end

    def to_native
      @struct.pointer
    end

    def name
      @struct[:display_name]
    end

    def screens
      read_screens
    end

    def file_descriptor
      X11::Xlib.XConnectionNumber(self.to_native)
    end

    def handle_events
      while pending_events > 0
        handle_event(next_event)
      end
    end

    def flush
      X11::Xlib.XFlush(self.to_native)
    end

    private
    def pending_events
      X11::Xlib.XPending(self.to_native)
    end

    def next_event
      x_event = X11::Xlib::XEvent.new
      X11::Xlib.XNextEvent(self.to_native, x_event) # blocks
      Event.new(x_event)
    end

    def handle_event(event)
      handling_window_id = event.event || event.parent || event.window
      handling_window = Window.new(self, handling_window_id)
      handling_window.handle(event) if handling_window
    end

    def screen_pointer(number)
      @struct[:screens] + (number * X11::Xlib::Screen.size)
    end

    def read_screen(number)
      Screen.new(self, screen_pointer(number))
    end

    def read_screens
      (0...@struct[:nscreens]).map do |screen_number|
        read_screen(screen_number)
      end
    end
  end
end