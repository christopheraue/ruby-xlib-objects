module XlibObj
  class Event
    def initialize(event)
      @event = event
      struct && struct.members.each do |key|
        define_singleton_method(key) { struct[key] }
      end
    end

    def name
      @name ||= x_name || xrr_name
    end

    private
    def type
      @type ||= @event[:type]
    end

    def union_member
      self.class::TYPE_TO_UNION_MEMBER[type]
    end

    def x_struct
      @event[union_member]
    end

    def xrr_type
      type-event_base
    end

    def xrr_type_struct
      @xrr_type_struct ||= self.class::RR_TYPE_TO_STRUCT[xrr_type].
        new(@event.pointer)
    end

    def xrr_subtype_struct
      if xrr_type_struct[:subtype]
        self.class::RR_SUBTYPE_TO_STRUCT[xrr_type_struct[:subtype]].
          new(@event.pointer)
      end
    end

    def xrr_struct
      xrr_subtype_struct || xrr_type_struct
    end

    def x_name
      self.class::TYPE.key(type)
    end

    def xrr_name
      xrr_subtype_name || xrr_type_name
    end

    def xrr_type_name
      @xrr_type_name ||= self.class::RR_TYPE.key(xrr_type)
    end

    def xrr_subtype_name
      if xrr_type_struct[:subtype]
        self.class::RR_SUBTYPE.key(xrr_type_struct[:subtype])
      end
    end

    def event_base
      self.class.event_base(@display)
    end

    class << self
      def event_base(display)
        @event_base[display] ||= (
          rr_event_base = FFI::MemoryPointer.new :int
          rr_error_base = FFI::MemoryPointer.new :int
          Xlib::XRRQueryExtension(display, rr_event_base, rr_error_base)
          rr_event_base.read_int
        )
      end

      def valid_name?(name)
        TYPE[name] || RR_SUBTYPE[name] || RR_TYPE[name]
      end

      MASK = {
        no_event:                 Xlib::NoEventMask,
        key_press:                Xlib::KeyPressMask,
        key_release:              Xlib::KeyReleaseMask,
        button_press:             Xlib::ButtonPressMask,
        button_release:           Xlib::ButtonReleaseMask,
        enter_window:             Xlib::EnterWindowMask,
        leave_window:             Xlib::LeaveWindowMask,
        pointer_motion:           Xlib::PointerMotionMask,
        pointer_motion_hint:      Xlib::PointerMotionHintMask,
        button1_motion:           Xlib::Button1MotionMask,
        button2_motion:           Xlib::Button2MotionMask,
        button3_motion:           Xlib::Button3MotionMask,
        button4_motion:           Xlib::Button4MotionMask,
        button5_motion:           Xlib::Button5MotionMask,
        button_motion:            Xlib::ButtonMotionMask,
        keymap_state:             Xlib::KeymapStateMask,
        exposure:                 Xlib::ExposureMask,
        visibility_change:        Xlib::VisibilityChangeMask,
        structure_notify:         Xlib::StructureNotifyMask,
        resize_redirect:          Xlib::ResizeRedirectMask,
        substructure_notify:      Xlib::SubstructureNotifyMask,
        substructure_redirect:    Xlib::SubstructureRedirectMask,
        focus_change:             Xlib::FocusChangeMask,
        property_change:          Xlib::PropertyChangeMask,
        colormap_change:          Xlib::ColormapChangeMask,
        owner_grab_button:        Xlib::OwnerGrabButtonMask,
        screen_change_notify:     Xlib::RRScreenChangeNotifyMask,
        crtc_change_notify:       Xlib::RRCrtcChangeNotifyMask,
        output_change_notify:     Xlib::RROutputChangeNotifyMask,
        output_property_notify:   Xlib::RROutputPropertyNotifyMask,
        provider_change_notify:   Xlib::RRProviderChangeNotifyMask,
        provider_property_notify: Xlib::RRProviderPropertyNotifyMask,
        resource_change_notify:   Xlib::RRResourceChangeNotifyMask
      }

      RR_MASK = {
        screen_change_notify:     Xlib::RRScreenChangeNotifyMask,
        crtc_change_notify:       Xlib::RRCrtcChangeNotifyMask,
        output_change_notify:     Xlib::RROutputChangeNotifyMask,
        output_property_notify:   Xlib::RROutputPropertyNotifyMask,
        provider_change_notify:   Xlib::RRProviderChangeNotifyMask,
        provider_property_notify: Xlib::RRProviderPropertyNotifyMask,
        resource_change_notify:   Xlib::RRResourceChangeNotifyMask
      }

      TYPE = {
        key_press:         Xlib::KeyPress,
        key_release:       Xlib::KeyRelease,
        button_press:      Xlib::ButtonPress,
        button_release:    Xlib::ButtonRelease,
        motion_notify:     Xlib::MotionNotify,
        enter_notify:      Xlib::EnterNotify,
        leave_notify:      Xlib::LeaveNotify,
        focus_in:          Xlib::FocusIn,
        focus_out:         Xlib::FocusOut,
        keymap_notify:     Xlib::KeymapNotify,
        expose:            Xlib::Expose,
        graphics_expose:   Xlib::GraphicsExpose,
        no_expose:         Xlib::NoExpose,
        visibility_notify: Xlib::VisibilityNotify,
        create_notify:     Xlib::CreateNotify,
        destroy_notify:    Xlib::DestroyNotify,
        unmap_notify:      Xlib::UnmapNotify,
        map_notify:        Xlib::MapNotify,
        map_request:       Xlib::MapRequest,
        reparent_notify:   Xlib::ReparentNotify,
        configure_notify:  Xlib::ConfigureNotify,
        configure_request: Xlib::ConfigureRequest,
        gravity_notify:    Xlib::GravityNotify,
        resize_request:    Xlib::ResizeRequest,
        circulate_notify:  Xlib::CirculateNotify,
        circulate_request: Xlib::CirculateRequest,
        property_notify:   Xlib::PropertyNotify,
        selection_clear:   Xlib::SelectionClear,
        selection_request: Xlib::SelectionRequest,
        selection_notify:  Xlib::SelectionNotify,
        colormap_notify:   Xlib::ColormapNotify,
        client_message:    Xlib::ClientMessage,
        mapping_notify:    Xlib::MappingNotify,
        generic_event:     Xlib::GenericEvent,
        last_event:        Xlib::LASTEvent
      }

      RR_TYPE = {
        screen_change_notify: Xlib::RRScreenChangeNotify,
        notify:               Xlib::RRNotify
      }

      RR_SUBTYPE = {
        crtc_change_notify:       Xlib::RRNotify_CrtcChange,
        output_change_notify:     Xlib::RRNotify_OutputChange,
        output_property_notify:   Xlib::RRNotify_OutputProperty,
        provider_change_notify:   Xlib::RRNotify_ProviderChange,
        provider_property_notify: Xlib::RRNotify_ProviderProperty,
        resource_change_notify:   Xlib::RRNotify_ResourceChange
      }

      TYPE_TO_UNION_MEMBER = {
        Xlib::KeyPress         => :xkey,
        Xlib::KeyRelease       => :xkey,
        Xlib::ButtonPress      => :xbutton,
        Xlib::ButtonRelease    => :xbutton,
        Xlib::MotionNotify     => :xmotion,
        Xlib::EnterNotify      => :xcrossing,
        Xlib::LeaveNotify      => :xcrossing,
        Xlib::FocusIn          => :xfocus,
        Xlib::FocusOut         => :xfocus,
        Xlib::KeymapNotify     => :xkeymap,
        Xlib::Expose           => :xexpose,
        Xlib::GraphicsExpose   => :xgraphicsexpose,
        Xlib::NoExpose         => :xnoexpose,
        Xlib::VisibilityNotify => :xvisibility,
        Xlib::CreateNotify     => :xcreatewindow,
        Xlib::DestroyNotify    => :xdestroywindow,
        Xlib::UnmapNotify      => :xunmap,
        Xlib::MapNotify        => :xmap,
        Xlib::MapRequest       => :xmaprequest,
        Xlib::ReparentNotify   => :xreparent,
        Xlib::ConfigureNotify  => :xconfigure,
        Xlib::ConfigureRequest => :xconfigurerequest,
        Xlib::GravityNotify    => :xgravity,
        Xlib::ResizeRequest    => :xresizerequest,
        Xlib::CirculateNotify  => :xcirculate,
        Xlib::CirculateRequest => :xcirculaterequest,
        Xlib::PropertyNotify   => :xproperty,
        Xlib::SelectionClear   => :xselectionclear,
        Xlib::SelectionRequest => :xselectionrequest,
        Xlib::SelectionNotify  => :xselection,
        Xlib::ColormapNotify   => :xcolormap,
        Xlib::ClientMessage    => :xclient,
        Xlib::MappingNotify    => :xmapping,
        Xlib::GenericEvent     => :xgeneric
      }

      RR_TYPE_TO_STRUCT = {
        Xlib::RRScreenChangeNotify => Xlib::XRRScreenChangeNotifyEvent,
        Xlib::RRNotify             => Xlib::XRRNotifyEvent
      }

      RR_SUBTYPE_TO_STRUCT = {
        Xlib::RRNotify_CrtcChange       => Xlib::XRRCrtcChangeNotifyEvent,
        Xlib::RRNotify_OutputChange     => Xlib::XRROutputChangeNotifyEvent,
        Xlib::RRNotify_OutputProperty   => Xlib::XRROutputPropertyNotifyEvent,
        Xlib::RRNotify_ProviderChange   => Xlib::XRRProviderChangeNotifyEvent,
        Xlib::RRNotify_ProviderProperty => Xlib::XRRProviderPropertyNotifyEvent,
        Xlib::RRNotify_ResourceChange   => Xlib::XRRResourceChangeNotifyEvent
      }
    end
  end
end