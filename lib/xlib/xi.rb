module Xlib
  module XI
    class << self
      def query_device(display, device_id)
        ndevices_ptr = FFI::MemoryPointer.new :int
        device_infos_ptr = Xlib::XIQueryDevice(display.to_native, device_id, ndevices_ptr)
        ndevices = ndevices_ptr.read_int

        0.upto(ndevices-1).map do |position|
          device_info_ptr = device_infos_ptr + position * Xlib::XIDeviceInfo.size
          Xlib::XIDeviceInfo.new(device_info_ptr)
        end
      end

      def set_focus(display, device, window, time)
        0 == Xlib::XISetFocus(display.to_native, device.to_native, window.to_native, time)
      end

      def get_focus(display, device)
        window_id_ptr = FFI::MemoryPointer.new :int
        if 0 == Xlib::XIGetFocus(display.to_native, device.to_native, window_id_ptr)
          window_id = window_id_ptr.read_int
          Window.new(display, window_id)
        end
      end

      def grab_device(display, device, window, time, cursor, mode, pair_mode, owner_events, event_mask)
        event_mask = EventMask.new(device, event_mask)
        0 == Xlib::XIGrabDevice(display.to_native, device.to_native, window.to_native, time, cursor,
          mode, pair_mode, owner_events, event_mask.to_native)
      end

      def ungrab_device(display, device, time)
        0 == Xlib::XIUngrabDevice(display.to_native, device.to_native, time).tap do
          Xlib::X.flush(display)
        end
      end

      def free_device_info(device_info)
        Xlib.XIFreeDeviceInfo(device_info.pointer)
        true
      end
    end
  end
end