module XlibObj
  class Screen
    def initialize(display, screen_pointer)
      @display = display
      @struct = Xlib::Screen.new(screen_pointer)

      ObjectSpace.define_finalizer(self) do
        Xlib.XRRFreeScreenResources(@resources.pointer) if @resources
      end
    end

    attr_reader :display

    def to_native
      @struct.pointer
    end

    def attribute(name)
      return unless @struct.layout.members.include? name.to_sym
      @struct[name]
    end

    def method_missing(name)
      attribute(name)
    end

    def number
      Xlib.XScreenNumberOfScreen(to_native)
    end

    def root_window
      @root_window ||= Window.new(@display, Xlib.XRootWindowOfScreen(to_native))
    end

    def crtcs
      (0..resources[:ncrtc]-1).map do |crtc_number|
        crtc_id(resources[:crtcs], crtc_number)
      end.map do |crtc_id|
        Crtc.new(self, crtc_id)
      end
    end

    private
    def resources
      unless @resources
        resources_ptr = Xlib.XRRGetScreenResources(@display.to_native,
          root_window.to_native)
        @resources = Xlib::XRRScreenResources.new(resources_ptr)
      end

      @resources
    end

    def read_item(pointer, item_pos, item_size)
      (pointer + item_pos*item_size).read_ulong
    end

    def crtc_id(pointer, number)
      read_item(pointer, number, FFI.type_size(:RRCrtc))
    end
  end
end