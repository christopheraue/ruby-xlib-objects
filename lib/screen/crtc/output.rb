module CappXlib
  class Screen
    class Crtcs
      class Output
        def initialize(crtc, id)
          @crtc = crtc
          @id = id
        end

        attr_reader :crtc, :id

        def attribute(attribute)
          attributes[attribute.to_sym]
        end

        def method_missing(name)
          attribute(name)
        end

        private
        def attributes
          unless @attributes
            screen_resources_ptr = Xlib.XRRGetScreenResources(@screen.
              display.to_native, @screen.root_window.to_native)
            output_info_ptr = Xlib.XRRGetOutputInfo(@screen.display.
              to_native, screen_resources_ptr, @id)
            @attributes = Xlib::XRROutputInfo.new(output_info_ptr)
            Xlib.XRRFreeScreenResources(screen_resources_ptr)
            Xlib.XRRFreeOutputInfo(output_info_ptr)
          end

          @attributes
        end
      end
    end
  end
end