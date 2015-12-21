module Xlib
  module XI
    class EventMask
      def initialize(devices, mask)
        @devices = devices
        @mask = mask
      end

      attr_reader :devices, :mask

      def to_native
        @structs ||= begin
          masks_ptr = FFI::MemoryPointer.new(Xlib::XIEventMask.size, @devices.count)

          @devices.each.with_index do |device, idx|
            byte_length = (@mask.bit_length/8.0).ceil
            mask_ptr = FFI::MemoryPointer.new :int
            mask_ptr.write_int @mask

            Xlib::XIEventMask.new(masks_ptr[idx]).tap do |event_mask|
              event_mask[:deviceid] = device.is_a?(XlibObj::InputDevice) ? device.id : device
              event_mask[:mask_len] = FFI.type_size(:int)
              event_mask[:mask] = mask_ptr
            end
          end

          Xlib::XIEventMask.new(masks_ptr[0]).pointer
        end
      end
    end
  end
end