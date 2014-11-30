module CappX11
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
            screen_resources_ptr = X11.XRRGetScreenResources(@screen.
              display.to_native, @screen.root_window.to_native)
            output_info_ptr = X11.XRRGetOutputInfo(@screen.display.
              to_native, screen_resources_ptr, @id)
            @attributes = X11::XRROutputInfo.new(output_info_ptr)
            X11.XRRFreeScreenResources(screen_resources_ptr)
            X11.XRRFreeOutputInfo(output_info_ptr)
          end

          @attributes
        end
      end
    end
  end
end