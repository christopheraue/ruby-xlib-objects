module XlibObj
  class Window
    class EventHandler
      def initialize(window)
        @window = window
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
        end
      end

      private
      def add_event_mask(mask)
        return if mask_in_use?(mask)
        @event_mask    |= normalize_mask(mask)
        @rr_event_mask |= normalize_rr_mask(mask)
        select_events
      end

      def remove_event_mask(mask)
        return if mask_in_use?(mask)
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
        @event_handlers[event][mask].delete(handler)
        @event_handlers[event].delete(mask) if @event_handlers[event][mask].empty?
        @event_handlers.delete(event) if @event_handlers[event].empty?
      end

      def mask_in_use?(mask)
        not @event_handlers.select do |_, handlers|
          handlers.has_key?(mask)
        end.empty?
      end

      def normalize_mask(mask)
        XlibObj::EVENT::MASK[mask] || 0
      end

      def normalize_rr_mask(mask)
        XlibObj::EVENT::RR_MASK[mask] || 0
      end

      def check_event(event)
        XlibObj::EVENT.valid_name?(event) || raise("Unknown event #{event}.")
      end

      def select_events
        Xlib.XSelectInput(display.to_native, window.to_native, @event_mask)
        Xlib.XRRSelectInput(display.to_native, window.to_native, @xrr_event_mask)
        Xlib.XFlush(display.to_native)
      end

      def display
        @window.display
      end

      def window
        @window
      end
    end
  end
end