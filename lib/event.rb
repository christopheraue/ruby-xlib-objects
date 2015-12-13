

module XlibObj
  class Event
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