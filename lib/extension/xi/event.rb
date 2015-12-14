module XlibObj
  class Extension::XI
    class Event
      def initialize(extension, event)
        @extension = extension
        @struct = self.class::TYPE_TO_STRUCT[event[:evtype]].new(event[:data])
      end

      def handle
        Window.new(@extension.display, event).handle(self)
      end

      def name
        TYPES.key(evtype)
      end

      def method_missing(name)
        @struct.members.include?(name) ? @struct[name] : nil
      end

      MASKS = {
        xi_device_changed: Xlib::XI_DeviceChangedMask,
        xi_key_press: Xlib::XI_KeyPressMask,
        xi_key_release: Xlib::XI_KeyReleaseMask,
        xi_button_press: Xlib::XI_ButtonPressMask,
        xi_button_release: Xlib::XI_ButtonReleaseMask,
        xi_motion: Xlib::XI_MotionMask,
        xi_enter: Xlib::XI_EnterMask,
        xi_leave: Xlib::XI_LeaveMask,
        xi_focus_in: Xlib::XI_FocusInMask,
        xi_focus_out: Xlib::XI_FocusOutMask,
        xi_hierarchy_changed: Xlib::XI_HierarchyChangedMask,
        xi_property_event: Xlib::XI_PropertyEventMask,
        xi_raw_key_press: Xlib::XI_RawKeyPressMask,
        xi_raw_key_release: Xlib::XI_RawKeyReleaseMask,
        xi_raw_button_press: Xlib::XI_RawButtonPressMask,
        xi_raw_button_release: Xlib::XI_RawButtonReleaseMask,
        xi_raw_motion: Xlib::XI_RawMotionMask,
        xi_touch_begin: Xlib::XI_TouchBeginMask,
        xi_touch_end: Xlib::XI_TouchEndMask,
        xi_touch_ownership_changed: Xlib::XI_TouchOwnershipChangedMask,
        xi_touch_update: Xlib::XI_TouchUpdateMask,
        xi_raw_touch_begin: Xlib::XI_RawTouchBeginMask,
        xi_raw_touch_end: Xlib::XI_RawTouchEndMask,
        xi_raw_touch_update: Xlib::XI_RawTouchUpdateMask,
        xi_barrier_hit: Xlib::XI_BarrierHitMask,
        xi_barrier_leave: Xlib::XI_BarrierLeaveMask
      }

      TYPES = {
        xi_device_changed: Xlib::XI_DeviceChanged,
        xi_key_press: Xlib::XI_KeyPress,
        xi_key_release: Xlib::XI_KeyRelease,
        xi_button_press: Xlib::XI_ButtonPress,
        xi_button_release: Xlib::XI_ButtonRelease,
        xi_motion: Xlib::XI_Motion,
        xi_enter: Xlib::XI_Enter,
        xi_leave: Xlib::XI_Leave,
        xi_focus_in: Xlib::XI_FocusIn,
        xi_focus_out: Xlib::XI_FocusOut,
        xi_hierarchy_changed: Xlib::XI_HierarchyChanged,
        xi_property_event: Xlib::XI_PropertyEvent,
        xi_raw_key_press: Xlib::XI_RawKeyPress,
        xi_raw_key_release: Xlib::XI_RawKeyRelease,
        xi_raw_button_press: Xlib::XI_RawButtonPress,
        xi_raw_button_release: Xlib::XI_RawButtonRelease,
        xi_raw_motion: Xlib::XI_RawMotion,
        xi_touch_begin: Xlib::XI_TouchBegin,
        xi_touch_end: Xlib::XI_TouchEnd,
        xi_touch_ownership_changed: Xlib::XI_TouchOwnership,
        xi_touch_update: Xlib::XI_TouchUpdate,
        xi_raw_touch_begin: Xlib::XI_RawTouchBegin,
        xi_raw_touch_end: Xlib::XI_RawTouchEnd,
        xi_raw_touch_update: Xlib::XI_RawTouchUpdate,
        xi_barrier_hit: Xlib::XI_BarrierHit,
        xi_barrier_leave: Xlib::XI_BarrierLeave
      }

      TYPE_TO_STRUCT = {
        Xlib::XI_DeviceChanged => Xlib::XIDeviceChangedEvent,
        Xlib::XI_KeyPress => Xlib::XIDeviceEvent,
        Xlib::XI_KeyRelease => Xlib::XIDeviceEvent,
        Xlib::XI_ButtonPress => Xlib::XIDeviceEvent,
        Xlib::XI_ButtonRelease => Xlib::XIDeviceEvent,
        Xlib::XI_Motion => Xlib::XIDeviceEvent,
        Xlib::XI_Enter => Xlib::XIEnterEvent,
        Xlib::XI_Leave => Xlib::XILeaveEvent,
        Xlib::XI_FocusIn => Xlib::XIFocusInEvent,
        Xlib::XI_FocusOut => Xlib::XIFocusOutEvent,
        Xlib::XI_HierarchyChanged => Xlib::XIHierarchyEvent,
        Xlib::XI_PropertyEvent => Xlib::XIPropertyEvent,
        Xlib::XI_RawKeyPress => Xlib::XIRawEvent,
        Xlib::XI_RawKeyRelease => Xlib::XIRawEvent,
        Xlib::XI_RawButtonPress => Xlib::XIRawEvent,
        Xlib::XI_RawButtonRelease => Xlib::XIRawEvent,
        Xlib::XI_RawMotion => Xlib::XIRawEvent,
        Xlib::XI_TouchBegin => Xlib::XIDeviceEvent,
        Xlib::XI_TouchEnd => Xlib::XIDeviceEvent,
        Xlib::XI_TouchOwnership => Xlib::XITouchOwnershipEvent,
        Xlib::XI_TouchUpdate => Xlib::XIDeviceEvent,
        Xlib::XI_RawTouchBegin => Xlib::XIRawEvent,
        Xlib::XI_RawTouchEnd => Xlib::XIRawEvent,
        Xlib::XI_RawTouchUpdate => Xlib::XIRawEvent,
        Xlib::XI_BarrierHit => Xlib::XIBarrierEvent,
        Xlib::XI_BarrierLeave => Xlib::XIBarrierEvent
      }
    end
  end
end