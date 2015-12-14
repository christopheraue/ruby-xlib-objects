#
# Copyright (c) 2014 Christopher Aue <mail@christopheraue.net>
#
# This file is part of the ruby xlib-objects gem. It is subject to the license
# terms in the LICENSE file found in the top-level directory of this
# distribution and at http://github.com/christopheraue/ruby-xlib-objects.
#

module XlibObj
  class Extension::XRR
    class Event
      def initialize(extension, event)
        @extension = extension
        @xrr_type = event[:type] - extension.first_event

        type_struct = TYPE_TO_STRUCT[@xrr_type].new(event.pointer)

        @struct = if type_struct.members.include?(:subtype)
          SUBTYPE_TO_STRUCT[type_struct[:subtype]].new(event.pointer)
        else
          type_struct
        end
      end

      def handle
        Window.new(@extension.display, window).handle(self)
      end

      def name
        @name ||= subtype ? SUBTYPES.key(subtype) : TYPES.key(@xrr_type)
      end

      def method_missing(name)
        @struct.members.include?(name) ? @struct[name] : nil
      end

      MASKS = {
        screen_change_notify:     Xlib::RRScreenChangeNotifyMask,
        crtc_change_notify:       Xlib::RRCrtcChangeNotifyMask,
        output_change_notify:     Xlib::RROutputChangeNotifyMask,
        output_property_notify:   Xlib::RROutputPropertyNotifyMask,
        provider_change_notify:   Xlib::RRProviderChangeNotifyMask,
        provider_property_notify: Xlib::RRProviderPropertyNotifyMask,
        resource_change_notify:   Xlib::RRResourceChangeNotifyMask
      }

      TYPES = {
        screen_change_notify: Xlib::RRScreenChangeNotify,
        notify:               Xlib::RRNotify
      }

      SUBTYPES = {
        crtc_change_notify:       Xlib::RRNotify_CrtcChange,
        output_change_notify:     Xlib::RRNotify_OutputChange,
        output_property_notify:   Xlib::RRNotify_OutputProperty,
        provider_change_notify:   Xlib::RRNotify_ProviderChange,
        provider_property_notify: Xlib::RRNotify_ProviderProperty,
        resource_change_notify:   Xlib::RRNotify_ResourceChange
      }

      TYPE_TO_STRUCT = {
        Xlib::RRScreenChangeNotify => Xlib::XRRScreenChangeNotifyEvent,
        Xlib::RRNotify             => Xlib::XRRNotifyEvent
      }

      SUBTYPE_TO_STRUCT = {
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