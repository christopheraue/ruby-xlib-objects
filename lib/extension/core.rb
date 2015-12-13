module XlibObj
  class Extension::Core < Extension
    def exists?
      true
    end

    def opcode
      0..127
    end

    def first_event
      2
    end

    def last_event
      Xlib::LASTEvent-1
    end

    def first_error
      0
    end

    def last_error
      127
    end

    private

    def native_interface
      Xlib::X
    end
  end
end