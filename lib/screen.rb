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
      screen_res = screen_resources
      outputs(screen_res).map do |output|
        crtc = crtc_info(screen_res, output[:crtc])
        SubScreen.new(self, output, crtc)
      end
    end

    private
    def screen_resources
      resources_ptr = X11::Xrandr.XRRGetScreenResources(display.to_native,
        root_window.to_native)
      X11::Xrandr::XRRScreenResources.new(resources_ptr)
    end

    def crtc_info(screen_resources, crtc)
      crtc_info_ptr = X11::Xrandr.XRRGetCrtcInfo(display.to_native,
        screen_resources.pointer, crtc)
      X11::Xrandr::XRRCrtcInfo.new(crtc_info_ptr)
    end

    def outputs(screen_resources)
      (0...screen_resources[:noutput]).map do |output_pos|
        output = output(screen_resources[:outputs], output_pos)
        output_info(screen_resources, output)
      end
    end

    def output(pointer, position)
      offset = position * (FFI.type_size(:RROutput))
      (pointer + offset).read_ulong
    end

    def output_info(screen_resources, output)
      output_info_ptr = X11::Xrandr.XRRGetOutputInfo(display.to_native,
        screen_resources.pointer, output)
      X11::Xrandr::XRROutputInfo.new(output_info_ptr)
    end
  end
end