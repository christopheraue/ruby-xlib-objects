class XlibObj::Display
  class Extension
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

    def first_error
      @attributes[:first_error]
    end
  end
end