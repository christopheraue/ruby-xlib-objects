module CappX11
  class Screen
    attr_reader :display

    def initialize(display, screen_pointer)
      @display = display
      @struct = X11::Xlib::Screen.new(screen_pointer)
    end

    def to_native
      @struct.pointer
    end

    def number
      X11::Xlib::XScreenNumberOfScreen(to_native)
    end

    def root_window
      window_id = X11::Xlib::XRootWindowOfScreen(self.to_native)
      Window.new(display, window_id)
    end

    def client_windows
      window_ids = root_window.property(:_NET_CLIENT_LIST)
      window_ids.map do |win_id|
        Window.new(display, win_id)
      end
    end

    def sub_screens
      outputs.map do |output|
        sub_screen = SubScreen.new(self, output[:name])
        X11::Xrandr.XRRFreeOutputInfo(output.pointer)
        sub_screen
      end
    end

    def outputs
      screen_res = screen_resources
      outputs = (0...screen_res[:noutput]).map do |output_pos|
        output_id = output_id(screen_res[:outputs], output_pos)
        output(screen_res, output_id)
      end
      X11::Xrandr.XRRFreeScreenResources(screen_res.pointer)
      outputs
    end

    private
    def screen_resources
      resources_ptr = X11::Xrandr.XRRGetScreenResources(
        display.to_native, root_window.to_native)
      X11::Xrandr::XRRScreenResources.new(resources_ptr)
    end

    def output_id(pointer, position)
      offset = position * (FFI.type_size(:RROutput))
      (pointer + offset).read_ulong
    end

    def output(screen_resources, output_id)
      output_ptr = X11::Xrandr.XRRGetOutputInfo(display.to_native,
        screen_resources.pointer, output_id)
      X11::Xrandr::XRROutputInfo.new(output_ptr)
    end
  end
end