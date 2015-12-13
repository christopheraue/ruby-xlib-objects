module XlibObj
  class Extension
    class << self
      def for(display, name)
        class_for(name).new(display, name)
      end

      private

      def class_for(name)
        case name
        when 'CORE' then Core
        when 'RANDR' then XRR
        when 'XInputExtension' then XI
        else self
        end
      end
    end

    def initialize(display, name)
      @display = display
      @name = name
      @attributes = Xlib::X.query_extension(@display, @name) || {}
    end

    attr_reader :display, :name

    def exists?
      not opcode.nil?
    end

    def opcode
      @attributes[:opcode]
    end

    def first_event
      @attributes[:first_event]
    end

    def last_event
      first_event
    end

    def event_range
      first_event..last_event
    end

    def first_error
      @attributes[:first_error]
    end

    def last_error
      first_error
    end

    def error_range
      first_error..last_error
    end

    def event(xevent)
      self.class::Event.new(self, xevent)
    end
  end
end