#
# Copyright (c) 2014 Christopher Aue <mail@christopheraue.net>
#
# This file is part of the ruby xlib-objects gem. It is subject to the license
# terms in the LICENSE file found in the top-level directory of this
# distribution and at http://github.com/christopheraue/ruby-xlib-objects.
#

module XlibObj
  class Error < StandardError
    def initialize(display, error)
      @display = display
      @error_code = error[:error_code]
      @request_code = error[:request_code]
      @minor_code = error[:minor_code]
      @resource = error[:resourceid]
    end

    def description
      "#{request_description}\n" <<
      "Error: #{error_description}\n" <<
      "Resource: #{resource_description}"
    end
    alias_method :message, :description

    def request_description
      @request_code < 128 ? major_request_description : minor_request_description
    end

    def major_request_description
      message_size = 256
      message = FFI::MemoryPointer.new(:char, message_size)
      Xlib.XGetErrorDatabaseText(@display.to_native, 'XRequest', "#{@request_code}",
        "Major code #{@request_code}", message, message_size)
      message.read_string
    end

    def minor_request_description
      message_size = 256
      message = FFI::MemoryPointer.new(:char, message_size)
      extension = @display.extensions.find{ |ext| ext.opcode == @request_code }
      Xlib.XGetErrorDatabaseText(@display.to_native, "XRequest.#{extension.name}", "#{@minor_code}",
        "Minor code #{@minor_code}", message, message_size)
      "#{extension.name} #{message.read_string}"
    end

    def error_description
      message_size = 256
      message = FFI::MemoryPointer.new(:char, message_size)
      Xlib.XGetErrorDatabaseText(@display.to_native, 'XProtoError', "#{@error_code}",
        "Error code #{@error_code}", message, message_size)
      message.read_string
    end

    def resource_description
      @resource
    end
  end
end