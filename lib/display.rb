module Xlib
  class Display
    class << self
      def open(name)
        display_pointer = Xlib::Capi.XOpenDisplay(name)

        raise ArgumentError, "Unknown display #{name}" if display_pointer.null?

        new(display_pointer)
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
      @struct = Capi::Display.new(display_pointer)
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
      Xlib::Capi.XConnectionNumber(self.to_native)
    end

    def handle_events
      while pending_events > 0
        handle_event(next_event)
      end
    end

    def flush
      Xlib::Capi.XFlush(self.to_native)
    end

    private
    def pending_events
      Xlib::Capi.XPending(self.to_native)
    end

    def next_event
      x_event = Xlib::Capi::XEvent.new
      Xlib::Capi.XNextEvent(self.to_native, x_event) # blocks
      Xlib::Event.new(x_event)
    end

    def handle_event(event)
      handling_window_id = event.event || event.parent || event.window
      handling_window = Xlib::Window.new(self, handling_window_id)
      handling_window.handle(event) if handling_window
    end

    def screen_pointer(number)
      @struct[:screens] + (number * Capi::Screen.size)
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