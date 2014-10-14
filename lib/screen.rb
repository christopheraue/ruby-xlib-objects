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
      crtcs(screen_resources).map { |crtc| SubScreen.new(self, crtc) }
    end

    private
    def screen_resources
      resources_ptr = X11::Xrandr.XRRGetScreenResources(display.to_native,
        root_window.to_native)
      X11::Xrandr::XRRScreenResources.new(resources_ptr)
    end

    def crtcs(screen_resources)
      (0...screen_resources[:ncrtc]).map do |crtc_pos|
        crtc = crtc(screen_resources[:crtcs], crtc_pos)
        crtc_info(screen_resources, crtc)
      end
    end

    def crtc(pointer, position)
      offset = position * (FFI.type_size(:RRCrtc))
      (pointer + offset).read_ulong
    end

    def crtc_info(screen_resources, crtc)
      crtc_info_ptr = X11::Xrandr.XRRGetCrtcInfo(display.to_native,
        screen_resources.pointer, crtc)
      X11::Xrandr::XRRCrtcInfo.new(crtc_info_ptr)
    end
  end
end