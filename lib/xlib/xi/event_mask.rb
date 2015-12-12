module Xlib
  module XI
    class EventMask
      def initialize(device, mask)
        @device = device
        @mask = mask
      end

      def struct
        @struct ||= begin
          byte_length = (@mask.bit_length/8.0).ceil
          mask_ptr = FFI::MemoryPointer.new :int
          mask_ptr.write_int @mask

          Xlib::XIEventMask.new.tap do |event_mask|
            event_mask[:deviceid] = @device.id
            event_mask[:mask_len] = FFI.type_size(:int)
            event_mask[:mask] = mask_ptr
          end
        end
      end

      def to_native
        struct.pointer
      end
    end
  end
end