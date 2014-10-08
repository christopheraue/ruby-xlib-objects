module Xlib
  class Display
    class << self
      def open(name)
        display_pointer = Xlib::Capi.XOpenDisplay(name)

        raise ArgumentError, "Unknown display #{name}" if display_pointer.null?

        new(display_pointer)
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