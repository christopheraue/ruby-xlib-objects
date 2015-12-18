#
# Copyright (c) 2014 Christopher Aue <mail@christopheraue.net>
#
# This file is part of the ruby xlib-objects gem. It is subject to the license
# terms in the LICENSE file found in the top-level directory of this
# distribution and at http://github.com/christopheraue/ruby-xlib-objects.
#

require 'socket'

module XlibObj
  class Display
    class << self
      def names
        Dir['/tmp/.X11-unix/*'].map do |file_name|
          match = file_name.match(/X(\d+)$/)
          ":#{match[1]}" if match
        end.compact
      end
    end

    def initialize(name)
      @struct = Xlib::X.open_display(name)
    end

    def to_native
      @struct.pointer
    end

    def name
      @struct[:display_name]
    end

    def socket
      @socket ||= UNIXSocket.for_fd(Xlib.XConnectionNumber(to_native))
    end

    def screens
      (0..@struct[:nscreens]-1).map{ |number| screen(number) }
    end

    def extensions
      @extensions ||= ['CORE', *Xlib::X.list_extensions(self)].map do |name|
        Extension.for(self, name)
      end
    end

    def input_devices
      device_infos = Xlib::XI.query_device(self, Xlib::XIAllDevices)
      device_ids = device_infos.map{ |dev| dev[:deviceid] }
      Xlib::XI.free_device_info(device_infos.first)
      device_ids.map do |device_id|
        InputDevice.new(self, device_id)
      end
    end

    def keyboards
      input_devices.select(&:keyboard?)
    end

    def pointers
      input_devices.select(&:pointer?)
    end

    def focused_window
      screens.reduce(nil){ |focused_window, s| focused_window or s.focused_window }
    end

    def handle_events
      while Xlib::X.pending(self) > 0
        xevent = Xlib::X.next_event(self)
        Event.new(self, xevent).extension_event.handle
      end
    end

    def selection(*args, &on_receive)
      internal_window.request_selection(*args, &on_receive)
      self
    end

    def set_selection(*args, &on_request)
      internal_window.set_selection(*args, &on_request)
      self
    end

    def on_error(&callback)
      @error_handler = if callback
        FFI::Function.new(:pointer, [:pointer, :pointer]) do |display_ptr, error_ptr|
          next if display_ptr != to_native
          x_error = Xlib::XErrorEvent.new(error_ptr)
          callback.call Error.new(self, x_error)
        end
      else
        nil
      end

      Xlib.XSetErrorHandler(@error_handler)
    end

    def on_io_error(&callback)
      @io_error_handler = if callback
        FFI::Function.new(:pointer, [:pointer]) do |display_ptr|
          next if display_ptr != to_native
          callback.call
        end
      else
        nil
      end

      Xlib.XSetIOErrorHandler(@io_error_handler)
    end

    def flush
      handle_events # XPending flushes the output buffer: http://tronche.com/gui/x/xlib/event-handling/XFlush.html
    end

    def close
      Xlib::X.close_display(self)
    end

    private

    def internal_window
      @internal_window ||= screen.root_window.create_window
    end

    def screen_pointer(number)
      @struct[:screens] + number*Xlib::Screen.size
    end

    def screen(number = 0)
      Screen.new(self, screen_pointer(number))
    end
  end
end