module CappX11
  class SubScreen
    attr_reader :screen, :display, :left, :top, :width, :height, :connected,
      :adapter
    alias_method :connected?, :connected

    def initialize(screen, output_name)
      @screen = screen
      @display = screen.display

      output = output_by_name(output_name)
      crtc = crtc(output[:crtc])

      @left = crtc[:x]
      @top = crtc[:y]
      @width = crtc[:width]
      @height = crtc[:height]
      @connected = output[:connection] == 0
      @adapter = output[:name]

      X11::Xrandr.XRRFreeOutputInfo(output.pointer)
      X11::Xrandr.XRRFreeCrtcInfo(crtc.pointer)
    end

    private
    def screen_resources(screen)
      resources_ptr = X11::Xrandr.XRRGetScreenResources(
        screen.display.to_native, screen.root_window.to_native)
      X11::Xrandr::XRRScreenResources.new(resources_ptr)
    end

    def crtc(crtc_id)
      screen_res = screen_resources(@screen)
      crtc_info_ptr = X11::Xrandr.XRRGetCrtcInfo(@display.to_native,
        screen_res.pointer, crtc_id)
      crtc = X11::Xrandr::XRRCrtcInfo.new(crtc_info_ptr)
      X11::Xrandr.XRRFreeScreenResources(screen_res.pointer)
      crtc
    end

    def output_by_name(output_name)
      @screen.outputs.select { |out| out[:name] == output_name }.first
    end
  end
end