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
      @event_masks = Hash.new{ |hash, key| hash[key] = Event::Mask.new }
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
      self.class::Event.new(self, xevent) if self.class.const_defined? :Event
    end

    def select_mask(window, mask)
      modify_mask(window, :add, mask)
    end

    def deselect_mask(window, mask)
      modify_mask(window, :subtract, mask)
    end

    def handles_event_mask?(mask)
      !!(self.class::Event::MASKS[mask] if self.class.const_defined?(:Event))
    end

    private

    def modify_mask(window, modification, mask)
      bit = self.class::Event::MASKS[mask]
      bit_mask = @event_masks[window.id].__send__(modification, bit)
      native_interface.select_input(@display, window, bit_mask)
    end
  end
end