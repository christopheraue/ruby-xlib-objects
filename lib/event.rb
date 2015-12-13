

module XlibObj
  class Event
    class << self
      def extension_events
        XlibObj::Extension.constants(false).map do |const|
          ext_class = XlibObj::Extension.const_get(const)
          ext_class::Event if ext_class.const_defined?(:Event)
        end.compact
      end

      def types
        extension_events.map do |event|
          if event.const_defined?(:SUBTYPES)
            event::TYPES.merge(event::SUBTYPES)
          else
            event::TYPES
          end
        end.reduce(&:merge)
      end

      def masks
        extension_events.map{ |event| event::MASKS }.reduce(&:merge)
      end

      def valid_name?(name)
        not types[name].nil?
      end

      def valid_mask?(mask)
        not masks[mask].nil?
      end
    end

    def initialize(display, xevent)
      @display = display
      @xevent = xevent
    end

    attr_reader :xevent

    def type
      @xevent[:type]
    end

    def generic?
      type == Xlib::GenericEvent
    end

    def cookie?
      @is_cookie ||= generic? and Xlib::X.get_event_data(@display, cookie)
    end

    def cookie
      @xevent[:xcookie]
    end

    def opcode
      cookie? and @event.cookie[:extension]
    end

    def extension
      @extension ||= @display.extensions.find do |ext|
        opcode == ext.opcode or ext.event_range.include?(type)
      end
    end

    def extension_event
      extension.event(@xevent)
    end
  end
end