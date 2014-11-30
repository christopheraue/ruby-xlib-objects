module CappXlib
  class Window
    class EventHandler
      def initialize(window)
        @window = window
        @event_handlers = {}
        @event_mask = 0
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
        if @event_handlers[event.type]
          @event_handlers[event.type].each do |_, handlers|
            handlers.each{ |handler| handler.call(event) }
          end
        end
      end

      private
      def add_event_mask(mask)
        check_event_mask(mask)
        return if mask_in_use?(mask)
        @event_mask |= CappXlib::EVENT::MASK[mask]
        select_events
      end

      def remove_event_mask(mask)
        check_event_mask(mask)
        return if mask_in_use?(mask)
        @event_mask &= ~CappXlib::EVENT::MASK[mask]
        select_events
      end

      def add_event_handler(mask, event, &handler)
        check_event(event)
        event_id = CappXlib::EVENT::Type[event]
        @event_handlers[event_id] ||= {}
        @event_handlers[event_id][mask] ||= []
        @event_handlers[event_id][mask] << handler
        handler
      end

      def remove_event_handler(mask, event, handler)
        check_event(event)
        event_id = CappXlib::EVENT::TYPE[event]
        @event_handlers[event_id][mask].delete(handler)
        @event_handlers[event_id].delete(mask) if @event_handlers[event_id][mask].empty?
        @event_handlers.delete(event_id) if @event_handlers[event_id].empty?
      end

      def mask_in_use?(mask)
        not @event_handlers.select do |_, handlers|
          handlers.has_key?(mask)
        end.empty?
      end

      def check_event_mask(mask)
        raise "Unknown event #{mask}." unless CappXlib::EVENT::MASK[mask]
      end

      def check_event(event)
        raise "Unknown event #{event}." unless CappXlib::EVENT::TYPE[event]
      end

      def select_events
        Xlib.XSelectInput(display.to_native, window.to_native, @event_mask)
        Xlib.XFlush(display.to_native)
      end

      def select_xrr_events
        # A XRRScreenChangeNotifyEvent is sent to a client that has requested
        # notification whenever the screen configuration is changed. A client
        # can perform this request by calling XRRSelectInput, passing the
        # display, the root window, and the RRScreenChangeNotifyMask mask.

        # see also
        # http://cgit.freedesktop.org/xorg/app/xev/tree/
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