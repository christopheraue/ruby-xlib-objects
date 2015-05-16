#
# Copyright (c) 2014 Christopher Aue <mail@christopheraue.net>
#
# This file is part of the ruby xlib-objects gem. It is subject to the license
# terms in the LICENSE file found in the top-level directory of this
# distribution and at http://github.com/christopheraue/ruby-xlib-objects.
#

module XlibObj
  class Window
    class EventHandler
      class << self
        def singleton(display, window_id)
          @handlers ||= {}
          @handlers[display] ||= {}
          @handlers[display][window_id] ||= new(display, window_id)
        end

        def remove(display, window_id)
          @handlers[display].delete(window_id) if @handlers and @handlers[display]
        end
      end

      def initialize(display, window_id)
        @display = display
        @window_id = window_id
        @event_handlers = {}
        @event_mask = 0
        @rr_event_mask = 0
      end

      def on(mask, event, &handler)
        add_event_mask(mask)
        add_event_handler(mask, event, &handler)
      end

      def off(mask, type, handler)
        remove_event_handler(mask, type, handler)
        remove_event_mask(mask)
      end

      def handle(event)
        if @event_handlers[event.name]
          @event_handlers[event.name].each do |_, handlers|
            handlers.each{ |handler| handler.call(event) }
          end
          true
        else
          false
        end
      end

      def destroy
        self.class.remove(@display, @window_id)
      end

      private
      def add_event_mask(mask)
        check_mask(mask)
        return if mask_in_use?(mask)
        @event_mask    |= normalize_mask(mask)
        @rr_event_mask |= normalize_rr_mask(mask)
        select_events
      end

      def remove_event_mask(mask)
        check_mask(mask)
        return if mask_in_use?(mask)
        return unless mask_selected?(mask)
        @event_mask    &= ~normalize_mask(mask)
        @rr_event_mask &= ~normalize_rr_mask(mask)
        select_events
      end

      def add_event_handler(mask, event, &handler)
        check_event(event)
        @event_handlers[event] ||= {}
        @event_handlers[event][mask] ||= []
        @event_handlers[event][mask] << handler
        handler
      end

      def remove_event_handler(mask, event, handler)
        check_event(event)
        return unless mask_in_use?(mask)
        return unless @event_handlers[event]
        @event_handlers[event][mask].delete(handler)
        @event_handlers[event].delete(mask) if @event_handlers[event][mask].empty?
        @event_handlers.delete(event) if @event_handlers[event].empty?
      end

      def mask_in_use?(mask)
        @event_handlers.select{ |_, handlers| handlers.has_key?(mask) }.any?
      end

      def mask_selected?(mask)
        (@event_mask & ~normalize_mask(mask) != @event_mask) or
          (@rr_event_mask & ~normalize_rr_mask(mask) != @rr_event_mask)
      end

      def check_mask(mask)
        if XlibObj::Event::MASK[mask].nil? && XlibObj::Event::RR_MASK[mask].nil?
          raise("Unknown event mask #{mask}.")
        end
      end

      def normalize_mask(mask)
        XlibObj::Event::MASK[mask] || 0
      end

      def normalize_rr_mask(mask)
        XlibObj::Event::RR_MASK[mask] || 0
      end

      def check_event(event)
        XlibObj::Event.valid_name?(event) || raise("Unknown event #{event}.")
      end

      def select_events
        Xlib.XSelectInput(@display.to_native, @window_id, @event_mask)
        Xlib.XRRSelectInput(@display.to_native, @window_id, @rr_event_mask)
        Xlib.XFlush(@display.to_native)
      end
    end
  end
end