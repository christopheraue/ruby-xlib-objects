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
      @instances = {}

      class << self
        def singleton(display, window)
          @instances[display] ||= {}
          @instances[display][window.id] ||= new(display, window)
        end

        def remove(display, window)
          @instances[display].delete(window.id) if @instances[display]
        end
      end

      def initialize(display, window)
        @display = display
        @window = window
        @event_handlers = {}
      end

      attr_reader :display, :window

      def on(mask, event, &handler)
        add_event_mask(mask)
        add_event_handler(mask, event, &handler)
      end

      def off(mask, event, handler = nil)
        remove_event_handler(mask, event, handler)
        remove_event_mask(mask)
      end

      def handle(event)
        @event_handlers.each do |mask, handlers|
          next unless handlers[event.name]
          handlers[event.name].each{ |handler| handler.call(event) }
        end
      end

      def destroy
        self.class.remove(@display, @window)
      end

      private

      def add_event_mask(mask)
        return if @event_handlers[mask]

        @event_handlers[mask] = {}
        extension = @display.extensions.find{ |ext| ext.handles_event_mask?(mask) }
        extension.select_mask(@window, mask)
      end

      def remove_event_mask(mask)
        return unless @event_handlers[mask].empty?

        extension = @display.extensions.find{ |ext| ext.handles_event_mask?(mask) }
        extension.deselect_mask(@window, mask)
        @event_handlers.delete(mask)
      end

      def add_event_handler(mask, event, &handler)
        @event_handlers[mask][event] ||= []
        @event_handlers[mask][event] << handler
        handler
      end

      def remove_event_handler(mask, event, handler)
        @event_handlers[mask][event].delete(handler)
        @event_handlers[mask].delete(event) if @event_handlers[mask][event].empty?
      end
    end
  end
end