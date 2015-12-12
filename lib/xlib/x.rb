module Xlib
  module X; end
  class << X
    def list_extensions(display)
      nextensions_ptr = FFI::MemoryPointer.new :pointer
      extensions_ptr = Xlib.XListExtensions(display.to_native, nextensions_ptr)
      nextensions = nextensions_ptr.read_int
      extensions = extensions_ptr.get_array_of_string(0, nextensions)
      Xlib.XFreeExtensionList(extensions_ptr)
      extensions
    end

    def query_extension(display, name)
      opcode_ptr = FFI::MemoryPointer.new :int
      evcode_ptr = FFI::MemoryPointer.new :int
      errcode_ptr = FFI::MemoryPointer.new :int
      if Xlib.XQueryExtension(display.to_native, name, opcode_ptr, evcode_ptr, errcode_ptr)
        { opcode: opcode_ptr.read_int, first_event: evcode_ptr.read_int, first_error: errcode_ptr.read_int}
      else
        false
      end
    end

    def get_event_data(display, cookie_event)
      Xlib::XGetEventData(display.to_native, cookie_event.pointer)
    end
  end
end