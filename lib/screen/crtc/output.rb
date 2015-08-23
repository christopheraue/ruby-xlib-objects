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
      class Output
        class << self
          def finalize(attributes)
            proc{ Xlib.XRRFreeOutputInfo(attributes.pointer) }
          end
        end

        def initialize(crtc, id)
          @crtc = crtc
          @id = id
        end

        attr_reader :crtc, :id

        def attribute(attribute)
          return unless attributes.layout.members.include? attribute.to_sym
          attributes[attribute.to_sym]
        end

        def method_missing(name)
          attribute(name)
        end

        private
        def attributes
          unless @attributes
            screen_resources_ptr = Xlib.XRRGetScreenResources(@crtc.screen.
              display.to_native, @crtc.screen.root_window.to_native)
            output_info_ptr = Xlib.XRRGetOutputInfo(@crtc.screen.display.
              to_native, screen_resources_ptr, @id)
            @attributes = Xlib::XRROutputInfo.new(output_info_ptr)
            ObjectSpace.define_finalizer(self, self.class.finalize(@attributes))
            Xlib.XRRFreeScreenResources(screen_resources_ptr)
          end

          @attributes
        end
      end
    end
  end
end