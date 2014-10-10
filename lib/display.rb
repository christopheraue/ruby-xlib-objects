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

    def handle_next_event
      x_event = Xlib::Capi::XEvent.new
      Xlib::Capi::XNextEvent(self.to_native, x_event) # blocks
      event = Xlib::Event.new(x_event)

      handling_window = Xlib::Window.get(
        event[:event] || event[:parent] || event[:window])
      handling_window.handle(event) if handling_window
    end

    private
    def screen_pointer(number)
      @struct[:screens] + (number * Capi::Screen.size)
    end

    def read_screen(number)
      Screen.new(self, screen_pointer(number), number)
    end

    def read_screens
      (0...@struct[:nscreens]).map do |screen_number|
        read_screen(screen_number)
      end
    end
  end
end