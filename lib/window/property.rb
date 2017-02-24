#
# Copyright (c) 2014 Christopher Aue <mail@christopheraue.net>
#
# This file is part of the ruby xlib-objects gem. It is subject to the license
# terms in the LICENSE file found in the top-level directory of this
# distribution and at http://github.com/christopheraue/ruby-xlib-objects.
#

module XlibObj
  class Window
    class Property
      def initialize(window, name)
        @window = window
        @name = name
        @atom = Atom.new(window.display, name)
      end

      def get
        return unless @atom.exists?

        data_offset     = 0
        data_max_length = 2**16  # multiple of 32 bit
        allow_deleted   = false  # don't retrieve deleted properties
        requested_type  = Xlib::AnyPropertyType

        # response data
        pointer     = FFI::MemoryPointer.new :pointer
        item_type   = FFI::MemoryPointer.new :Atom
        item_width  = FFI::MemoryPointer.new :int
        item_count  = FFI::MemoryPointer.new :ulong
        cutoff_data = FFI::MemoryPointer.new :ulong

        # do and validate the request
        status = Xlib.XGetWindowProperty(
          @window.display.to_native, @window.to_native, @atom.to_native,
          data_offset, data_max_length, allow_deleted, requested_type,
          item_type, item_width, item_count, cutoff_data, pointer
        )

        return unless status == 0

        return if pointer.read_pointer.null? # property is not set for the window

        # extract response data
        item_type = Atom.new(@window.display, item_type.read_int).name
        item_width = item_width.read_int
        item_count = item_count.read_int

        return if item_count == 0

        # get the property's value
        bytes = read_bytes(pointer, item_width, item_count)
        items = bytes_to_items(bytes, item_type, item_count)

        return if items.empty?

        items_to_objects(items, item_type)
      end

      def set(value, type = nil)
        objects = value.is_a?(Array) ? value : [value]
        item_type = type || type_from_objects(objects)
        items = objects_to_items(objects, item_type)
        item_width = width_from_type(item_type)
        bytes = items_to_bytes(items, item_type)
        item_count = item_type[-6..-1] == 'STRING' ? bytes.size : items.size

        Xlib.XChangeProperty(
          @window.display.to_native, @window.to_native, @atom.to_native,
          Atom.new(@window.display, item_type).to_native, item_width,
          Xlib::PropModeReplace, bytes, item_count)
        Xlib::X.flush(@window.display)

        self
      end

      def delete
        Xlib.XDeleteProperty(@window.display.to_native, @window.to_native, @atom.to_native)
      end

      private
      def read_bytes(pointer, width, count)
        pointer.read_pointer.read_string(count*native_width(width))
      end

      def native_width(width)
        # translate word size to platform dependent bit count
        FFI.type_size({ 8 => :char, 16 => :short, 32 => :long }[width])
      end

      def width(native_width)
        { char: 8, short: 16, long: 32 }[native_width]
      end

      def bytes_to_items(bytes, type, item_count)
        if [:STRING, :UTF8_STRING].include? type
          bytes.split("\0")
        else
          bytes.unpack(format(type) * item_count)
        end
      end

      def items_to_bytes(items, type)
        items.pack(format(type) * items.size)
      end

      def format(type)
        case type
        when :INTEGER     then 'i!'
        when :CARDINAL    then 'L!'
        when :ATOM        then 'L!'
        when :WINDOW      then 'L!'
        when :STRING      then 'Z*'
        when :UTF8_STRING then 'Z*'
        else 'a'
        end
      end

      def items_to_objects(items, type)
        transform = case type
                    when :UTF8_STRING
                      Proc.new{ |s| s.force_encoding('UTF-8') }
                    when :ATOM
                      Proc.new{ |a| Atom.new(@window.display, a) }
                    when :WINDOW
                      Proc.new{ |w| Window.new(@window.display, w) }
                    else
                      Proc.new{ |a| a }
                    end

        items.map(&transform)
      end

      def objects_to_items(objects, type)
        transform = case type
                    when :ATOM
                      Proc.new{ |a| a.to_native }
                    when :WINDOW
                      Proc.new{ |w| w.to_native }
                    else
                      Proc.new{ |a| a }
                    end

        objects.map(&transform)
      end

      def type_from_objects(objects)
        if objects.all? { |o| o.is_a? Window }
          :WINDOW
        elsif objects.all? { |o| o.is_a? Atom }
          :ATOM
        elsif objects.all? { |o| o.is_a? Integer }
          if objects.any? { |o| o < 0 }
            :INTEGER
          else
            :CARDINAL
          end
        elsif objects.all? { |o| o.is_a? String }
          if objects.any? { |o| o.encoding == Encoding::UTF_8 }
            :UTF8_STRING
          else
            :STRING
          end
        else
          :BYTES
        end
      end

      def width_from_type(type)
        case type
        when :INTEGER     then 16
        when :CARDINAL    then 32
        when :ATOM        then 32
        when :WINDOW      then 32
        when :STRING      then 8
        when :UTF8_STRING then 8
        else 8
        end
      end
    end
  end
end