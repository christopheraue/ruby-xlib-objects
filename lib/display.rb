module CappX11
  class Display
    class << self
      def names
        Dir['/tmp/.X11-unix/*'].map do |file_name|
          match = file_name.match(/X(\d+)$/)
          ":#{match[1]}" if match
        end.compact
      end
    end

    def initialize(name)
      display_pointer = X11.XOpenDisplay(name)
      raise ArgumentError, "Unknown display #{name}" if display_pointer.null?
      @struct = X11::Display.new(display_pointer)
    end

    def to_native
      @struct.pointer
    end

    def name
      @struct[:display_name]
    end

    def screens
      (0..@struct[:nscreens]-1).map{ |number| screen(number) }
    end

    def socket
      UNIXSocket.for_fd(X11.XConnectionNumber(to_native))
    end

    def handle_events
      handle_event(next_event) while pending_events > 0
    end

    private
    def pending_events
      X11.XPending(to_native)
    end

    def next_event
      x_event = X11::XEvent.new
      X11.XNextEvent(to_native, x_event) # blocks
      Event.new(x_event)
    end

    def handle_event(event)
      handling_window_id = event.event || event.parent || event.window
      handling_window = Window.new(self, handling_window_id)
      handling_window.handle(event) if handling_window
    end

    def screen_pointer(number)
      @struct[:screens] + number*X11::Screen.size
    end

    def screen(number)
      Screen.new(self, screen_pointer(number))
    end
  end
end