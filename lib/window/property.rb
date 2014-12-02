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

        data_offset = 0           # data offset
        data_max_length = 2**16   # max data length, multiple of 32 bit
        allow_deleted = false     # don't retrieve deleted properties
        requested_type = Xlib::AnyPropertyType

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

        raise 'Getting property value failed.' unless status == 0

        return if pointer.read_pointer.null? # property is not set for the window

        # extract response data
        item_type = Atom.new(@window.display, item_type.read_int).name
        item_width = item_width.read_int
        item_count = item_count.read_int

        return if item_count == 0

        # get the property's value
        bytes = read_bytes(pointer, item_width, item_count)
        items = bytes_to_items(bytes, item_type)

        return if items.empty?

        items = items_to_objects(items, item_type)

        items.length == 1 ? items.first : items
      end

      def set(value)
        items = value.is_a?(Array) ? value : [value]
        item_count = items.size
        item_type = type_from_item(items.first)
        item_width = width_from_type(item_type)
        bytes = items_to_bytes(items, item_type)

        Xlib.XChangeProperty(
          @window.display.to_native, @window.to_native, @atom,
          item_type, item_width, Xlib::PropModeReplace, bytes, item_count
        )
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

      def bytes_to_items(bytes, type)
        bytes.unpack(format(type))
      end

      def items_to_bytes(items, type)
        items.pack(format(type))
      end

      def format(type)
        case type
        when :CARDINAL    then 'I!*'
        when :INTEGER     then 'i!*'
        when :ATOM        then 'L!*'
        when :WINDOW      then 'L!*'
        when :STRING      then 'Z*'
        when :UTF8_STRING then 'Z*'
        else 'A'
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
                    when :UTF8_STRING
                      Proc.new{ |s| s.force_encoding('ASCII-8BIT') }
                    when :ATOM
                      Proc.new{ |a| a.to_native }
                    when :WINDOW
                      Proc.new{ |w| w.to_native }
                    else
                      Proc.new{ |a| a }
                    end

        objects.map(&transform)
      end

      def type_from_item(item)
        if item.is_a? Window
          :WINDOW
        elsif item.is_a? Atom
          :ATOM
        elsif item.is_a? Integer
          if item >= 0
            :CARDINAL
          else
            :INTEGER
          end
        elsif item.is_a? String
          if item.encoding == Encoding::UTF_8
            :UTF8_STRING
          else
            :STRING
          end
        end
      end

      def width_from_type(type)
        case type
        when :CARDINAL    then 16
        when :INTEGER     then 16
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