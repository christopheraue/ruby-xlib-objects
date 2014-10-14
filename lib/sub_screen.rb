module CappX11
  class SubScreen
    attr_reader :screen, :display

    def initialize(screen, output, crtc)
      @screen = screen
      @display = screen.display
      @crtc = crtc
      @output = output
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

    def connected?
      @output[:connection] == 0
    end

    def adapter
      @output[:name]
    end
  end
end