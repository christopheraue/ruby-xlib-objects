#
# Copyright (c) 2014 Christopher Aue <mail@christopheraue.net>
#
# This file is part of the ruby xlib-objects gem. It is subject to the license
# terms in the LICENSE file found in the top-level directory of this
# distribution and at http://github.com/christopheraue/ruby-xlib-objects.
#

module XlibObj
  class Error
    def initialize(display, error)
      @display = display
      @error = error
    end

    def code
      @error[:error_code]
    end

    def minor_code
      @error[:minor_code]
    end

    def request
      @error[:request_code]
    end

    def resource
      @error[:resourceid]
    end

    def description
      "#{general_description}\n" <<
      " #{code_description}\n" <<
      ((code >= 128) ? " #{minor_code_description}\n" : "") <<
      " #{resource_description}"
    end

    def general_description
      type_size = 2**16
      type = FFI::MemoryPointer.new(:char, type_size)
      Xlib.XGetErrorDatabaseText(@display.to_native, @display.name, 'XError', 'X Error', type,
        type_size)

      details_size = 2**16
      details = FFI::MemoryPointer.new(:char, details_size)
      Xlib.XGetErrorText(@display.to_native, code, details, details_size)

      "#{type.read_string}: #{details.read_string}"
    end

    def code_description
      message_size = 2**16
      message = FFI::MemoryPointer.new(:char, message_size)
      Xlib.XGetErrorDatabaseText(@display.to_native, @display.name, 'MajorCode',
        'Request Major code %d', message, message_size)
      message.read_string.gsub('%d', code.to_s)
    end

    def minor_code_description
      message_size = 2**16
      message = FFI::MemoryPointer.new(:char, message_size)
      Xlib.XGetErrorDatabaseText(@display.to_native, @display.name, 'MinorCode',
        'Request Minor code %d', message, message_size)
      message.read_string.gsub('%d', minor_code.to_s)
    end

    def resource_description
      message_size = 2**16
      message = FFI::MemoryPointer.new(:char, message_size)

      if [Xlib::BadWindow, Xlib::BadPixmap, Xlib::BadCursor, Xlib::BadFont, Xlib::BadDrawable,
        Xlib::BadColor, Xlib::BadGC, Xlib::BadIDChoice].include?(code)
        Xlib.XGetErrorDatabaseText(@display.to_native, @display.name, "ResourceID",
          "ResourceID 0x%x", message, message_size)
      elsif code == Xlib::BadValue
        Xlib.XGetErrorDatabaseText(@display.to_native, @display.name, "Value", "Value 0x%x",
          message, message_size)
      elsif code == Xlib::BadAtom
        Xlib.XGetErrorDatabaseText(@display.to_native, @display.name, "AtomID", "AtomID 0x%x",
          message, message_size)
      end

      message.read_string.gsub('%x', resource.to_s)
    end
  end
end