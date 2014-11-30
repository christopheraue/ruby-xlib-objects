module CappX11
  class Screen
    class Crtc
      def initialize(screen, id)
        @screen = screen
        @id = id
      end

      attr_reader :screen, :id

      def attribute(attribute)
        attributes[attribute.to_sym]
      end

      def method_missing(name)
        attribute(name)
      end

      def outputs
        (0..attributes[:noutput]-1).map do |output_number|
          output_id(resources[:outputs], output_number)
        end.map do |output_id|
          Output.new(crtc, output_id)
        end
      end

      private
      def attributes
        unless @attributes
          screen_resources_ptr = X11.XRRGetScreenResources(@screen.
            display.to_native, @screen.root_window.to_native)
          crtc_info_ptr = X11.XRRGetCrtcInfo(@screen.display.to_native,
            screen_resources_ptr, @id)
          @attributes = X11::XRRCrtcInfo.new(crtc_info_ptr)
          X11.XRRFreeScreenResources(screen_resources_ptr)
          X11.XRRFreeCrtcInfo(crtc_info_ptr)
        end

        @attributes
      end

      def read_item(pointer, item_pos, item_size)
        (pointer + item_pos*item_size).read_ulong
      end

      def output_id(pointer, number)
        read_item(pointer, number, FFI.type_size(:RROutput))
      end
    end
  end
end