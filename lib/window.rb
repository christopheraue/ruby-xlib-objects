module Xlib
  class Window
    attr_reader :screen

    def initialize(screen, window_id)
      @screen = screen
      @native = window_id
    end

    def to_native
      @native
    end

    def left
      attributes[:x]
    end

    def top
      attributes[:y]
    end

    def width
      attributes[:width]
    end

    def height
      attributes[:height]
    end

    def mapped?
      attributes[:map_state] != 'IsUnmapped'
    end

    def visible?
      attributes[:map_state] == 'IsViewable'
    end

    def display
      screen.display
    end

    def property(name)
      Property.get(self, name).value
    end

    def properties
      Property.all(self)
    end

    private
    def attributes
      attributes = Capi::WindowAttributes.new
      Capi::XGetWindowAttributes(display.to_native, self.to_native, attributes.pointer)
      attributes
    end
  end
end