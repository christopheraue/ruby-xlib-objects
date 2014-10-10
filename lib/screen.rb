module Xlib
  class Screen
    attr_reader :display

    def initialize(display, screen_pointer)
      @display = display
      @struct = Xlib::Capi::Screen.new(screen_pointer)
    end

    def to_native
      @struct.pointer
    end

    def root_window
      window_id = Capi::XRootWindowOfScreen(self.to_native)
      Xlib::Window.new(display, window_id)
    end

    def client_windows
      window_ids = root_window.property(:_NET_CLIENT_LIST)
      window_ids.map do |win_id|
        Xlib::Window.new(display, win_id)
      end
    end
  end
end