module Xlib
  class Screen
    attr_reader :display

    def initialize(display, screen_pointer, number)
      @display = display
      @struct = Xlib::Capi::Screen.new(screen_pointer)
      @number = number
    end

    def to_native
      @struct.pointer
    end

    def root_window
      window_id = Capi::XRootWindowOfScreen(self.to_native)
      Xlib::Window.new(self, window_id)
    end
  end
end