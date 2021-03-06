#
# Copyright (c) 2014 Christopher Aue <mail@christopheraue.net>
#
# This file is part of the ruby xlib-objects gem. It is subject to the license
# terms in the LICENSE file found in the top-level directory of this
# distribution and at http://github.com/christopheraue/ruby-xlib-objects.
#

module XlibObj
  class Screen
    class Crtc
      class << self
        def finalize(attributes)
          proc{ Xlib.XRRFreeCrtcInfo(attributes.pointer) }
        end
      end

      def initialize(screen, id)
        @screen = screen
        @id = id
      end

      attr_reader :screen, :id

      def attribute(attribute)
        return unless attributes.layout.members.include? attribute.to_sym
        attributes[attribute.to_sym]
      end

      def method_missing(name)
        attribute(name)
      end

      def outputs
        (0..attribute(:noutput)-1).map do |output_number|
          output_id(attribute(:outputs), output_number)
        end.map do |output_id|
          Output.new(self, output_id)
        end
      end

      private
      def attributes
        unless @attributes
          screen_resources_ptr = Xlib.XRRGetScreenResources(@screen.
            display.to_native, @screen.root_window.to_native)
          crtc_info_ptr = Xlib.XRRGetCrtcInfo(@screen.display.to_native,
            screen_resources_ptr, @id)
          @attributes = Xlib::XRRCrtcInfo.new(crtc_info_ptr)
          ObjectSpace.define_finalizer(self, self.class.finalize(@attributes))
          Xlib.XRRFreeScreenResources(screen_resources_ptr)
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