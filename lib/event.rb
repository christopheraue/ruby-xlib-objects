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

    def data?
      @is_cookie ||= generic? && Xlib::X.get_event_data(@display, cookie)
    end

    def cookie
      @xevent[:xcookie]
    end

    def opcode
      (data? and cookie[:extension])
    end

    def extension
      @extension ||= @display.extensions.find do |ext|
        data? ? opcode == ext.opcode : ext.event_range.include?(type)
      end
    end

    def extension_event
      extension.event(data? ? cookie : xevent)
    end
  end
end