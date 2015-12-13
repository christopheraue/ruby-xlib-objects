module XlibObj
  class Extension::Core < Extension
    def initialize(display, name)
      @display = display
      @name = name
    end

    attr_reader :display, :name

    def exists?
      true
    end

    def opcode
      0..127
    end

    def event_range
      2..Xlib::LASTEvent-1
    end

    def error_range
      0..127
    end
  end
end