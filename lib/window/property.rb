module CappX11
  module Window::Property
    class << self
      def get(window, name)
        # request data
        atom = if name.is_a? Integer
                 name
               else
                 X11::Xlib.XInternAtom(window.display.to_native, name.to_s, true)
               end

        return nil if atom == 0 # property does not exist

        data_offset = 0           # data offset
        data_max_length = 2**16   # max data length, multiple of 32 bit
        allow_deleted = false     # don't retrieve deleted properties
        requested_type = X11::Xlib::ANY_PROPERTY_TYPE

        # response data
        pointer     = FFI::MemoryPointer.new :pointer
        type        = FFI::MemoryPointer.new :Atom
        item_size   = FFI::MemoryPointer.new :int
        item_count  = FFI::MemoryPointer.new :ulong
        cutoff_data = FFI::MemoryPointer.new :ulong

        # do and validate the request
        status = X11::Xlib.XGetWindowProperty(
          window.display.to_native, window.to_native,
          atom, data_offset, data_max_length, allow_deleted, requested_type,
          type, item_size, item_count, cutoff_data, pointer
        )

        raise 'Retrieve the property failed with error status.' unless status == 0
        #raise 'Cut property data off after maximal length.' if cutoff_data.read_ulong != 0

        return nil if pointer.read_pointer.null? # property is not set for the window

        # get the property's value
        get_value(window, pointer, {
          item_size: item_size.read_int,
          item_count: item_count.read_ulong,
          type: X11::Xlib.XGetAtomName(window.display.to_native, type.read_int).to_sym
        })
      end

      def all(window)
        display_ptr = window.display.to_native
        window_id = window.to_native

        # query list of properties (comes back as list of atoms)
        count_ptr = FFI::MemoryPointer.new :int
        atoms_ptr = X11::Xlib.XListProperties(display_ptr, window_id, count_ptr)
        count = count_ptr.read_int

        # map atoms to names
        names = atoms_ptr.read_array_of_ulong(count).map do |atom|
          X11::Xlib.XGetAtomName(display_ptr, atom)
        end

        # free atom list
        X11::Xlib.XFree(atoms_ptr)

        # map names to properties
        props = names.map do |name|
          [name.to_sym, get(window, name)]
        end

        props.to_h
      end

      private
      def get_value(window, pointer, data_options)
        raw_data = read_raw_data(pointer, data_options)
        parse_raw_data(window, raw_data, data_options)
      end

      def read_raw_data(pointer, data_options)
        item_size = data_options[:item_size]
        item_count  = data_options[:item_count]

        data_length = item_count * item_size_in_byte(item_size)
        pointer.read_pointer.read_string(data_length)
      end

      def parse_raw_data(window, data, data_options)
        value = if [:STRING, :UTF8_STRING].include?(data_options[:type])
          parse_string_data(data, data_options)
        else
          parse_non_string_data(data, data_options)
        end

        if data_options[:type] == :ATOM
          value.map! do |atom|
            X11::Xlib.XGetAtomName(window.display.to_native, atom)
          end
        end

        value.length <= 1 ? value.first : value
      end

      def parse_string_data(data, data_options)
        if data_options[:type] == :STRING
          data.force_encoding('ASCII-8BIT')
        else
          data.force_encoding('UTF-8')
        end

        data.split("\0")
      end

      def parse_non_string_data(data, data_options)
        directive = case data_options[:type]
                    when :CARDINAL    then 'I!'
                    when :ATOM        then 'L!'
                    when :INTEGER     then 'i!'
                    when :WINDOW      then 'L!'
                    else return ['Query handler not implemented for this property type.']
                    end

        slice_size = data.bytes.length / data_options[:item_count]
        slices = data.each_char.each_slice(slice_size).map(&:join)
        slices.map do |slice|
          slice.unpack(directive)
        end.flatten
      end

      def item_size_in_byte(item_size)
        # translate word size to platform dependent byte count
        FFI.type_size({
          0 => :void,
          8 => :char,
          16 => :short,
          32 => :long
        }[item_size])
      end
    end
  end
end