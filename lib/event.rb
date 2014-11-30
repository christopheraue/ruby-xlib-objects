module CappXlib
  class Event
    attr_reader :struct, :name

    def initialize(union)
      event = union[:type]
      union_member = self.class::TYPE_TO_UNION[event]
      @name = self.class::NAME.key(event)
      @struct = union[union_member]

      @struct.members.each do |key|
        define_singleton_method(key) do
          @struct[key]
        end
      end
    end

    class << self
      MASK = {
        no_event:              Xlib::NoEventMask,
        key_press:             Xlib::KeyPressMask,
        key_release:           Xlib::KeyReleaseMask,
        button_press:          Xlib::ButtonPressMask,
        button_release:        Xlib::ButtonReleaseMask,
        enter_window:          Xlib::EnterWindowMask,
        leave_window:          Xlib::LeaveWindowMask,
        pointer_motion:        Xlib::PointerMotionMask,
        pointer_motion_hint:   Xlib::PointerMotionHintMask,
        button1_motion:        Xlib::Button1MotionMask,
        button2_motion:        Xlib::Button2MotionMask,
        button3_motion:        Xlib::Button3MotionMask,
        button4_motion:        Xlib::Button4MotionMask,
        button5_motion:        Xlib::Button5MotionMask,
        button_motion:         Xlib::ButtonMotionMask,
        keymap_state:          Xlib::KeymapStateMask,
        exposure:              Xlib::ExposureMask,
        visibility_change:     Xlib::VisibilityChangeMask,
        structure_notify:      Xlib::StructureNotifyMask,
        resize_redirect:       Xlib::ResizeRedirectMask,
        substructure_notify:   Xlib::SubstructureNotifyMask,
        substructure_redirect: Xlib::SubstructureRedirectMask,
        focus_change:          Xlib::FocusChangeMask,
        property_change:       Xlib::PropertyChangeMask,
        colormap_change:       Xlib::ColormapChangeMask,
        owner_grab_button:     Xlib::OwnerGrabButtonMask
      }

      # Event names
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

      TYPE_TO_UNION = {
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
    end
  end
end