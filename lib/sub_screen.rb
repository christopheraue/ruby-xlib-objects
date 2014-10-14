module CappX11
  class SubScreen
    attr_reader :screen, :display

    def initialize(screen, crtc)
      @screen = screen
      @display = screen.display
      @crtc = crtc
    end

    def left
      @crtc[:x]
    end

    def top
      @crtc[:y]
    end

    def width
      @crtc[:width]
    end

    def height
      @crtc[:height]
    end
  end
end