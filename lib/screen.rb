#
# Copyright (c) 2014 Christopher Aue <mail@christopheraue.net>
#
# This file is part of the ruby xlib-objects gem. It is subject to the license
# terms in the LICENSE file found in the top-level directory of this
# distribution and at http://github.com/christopheraue/ruby-xlib-objects.
#

module XlibObj
  class Screen
    class << self
      def finalize(resources)
        proc{ Xlib.XRRFreeScreenResources(resources.pointer) }
      end
    end

    def initialize(display, screen_pointer)
      @display = display
      @struct = Xlib::Screen.new(screen_pointer)
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

    def focused_window
      window_ptr = FFI::MemoryPointer.new :Window
      trash_ptr  = FFI::MemoryPointer.new :int
      Xlib.XGetInputFocus(@display.to_native, window_ptr, trash_ptr)
      window = window_ptr.read_int

      if window == Xlib::PointerRoot
        root_window
      elsif window == Xlib::None
        nil
      else
        Window.new(@display, window)
      end
    end

    def crtcs
      (0..resources[:ncrtc]-1).map do |crtc_number|
        crtc_id(resources[:crtcs], crtc_number)
      end.map do |crtc_id|
        Crtc.new(self, crtc_id)
      end
    end

    def inspect
      "#<#{self.class.name}:0x#{'%014x' % __id__} @number=#{number}>"
    end

    private

    def resources
      unless @resources
        resources_ptr = Xlib.XRRGetScreenResources(@display.to_native,
          root_window.to_native)
        @resources = Xlib::XRRScreenResources.new(resources_ptr)
        ObjectSpace.define_finalizer(self, self.class.finalize(@resources))
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