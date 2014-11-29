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

    def crtcs
      (0..resources[:ncrtcs]-1).map do |crtc_number|
        crtc_id(resources[:crtcs], crtc_number)
      end.map do |crtc_id|
        Crtc.new(screen, crtc_id)
      end
    end

    private
    def resources
      unless @resources
        resources_ptr = X11::Xrandr.XRRGetScreenResources(display.to_native,
          root_window.to_native)
        @resources = X11::Xrandr::XRRScreenResources.new(resources_ptr)
        X11::Xrandr.XRRFreeScreenResources(resources_ptr)
      end

      @resources
    end

    def read_item(pointer, item_pos, item_size)
      (pointer + item_pos*item_size).read_ulong
    end

    def crtc_id(pointer, number)
      read_item(pointer, number, FFI.type_size(:RRCrtc))
    end

    def output(screen_resources, output_id)
      output_ptr = X11::Xrandr.XRRGetOutputInfo(display.to_native,
        screen_resources.pointer, output_id)
      X11::Xrandr::XRROutputInfo.new(output_ptr)
    end
  end
end