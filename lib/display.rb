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
      display_pointer = Xlib.XOpenDisplay(name)
      raise ArgumentError, "Unknown display #{name}" if display_pointer.null?
      @struct = Xlib::Display.new(display_pointer)
    end

    def to_native
      @struct.pointer
    end

    def name
      @struct[:display_name]
    end

    def socket
      UNIXSocket.for_fd(Xlib.XConnectionNumber(to_native))
    end

    def screens
      (0..@struct[:nscreens]-1).map{ |number| screen(number) }
    end

    def focused_window
      screens.reduce(nil){ |focused_window, s| focused_window or s.focused_window }
    end

    def handle_events
      handle_event(next_event) while pending_events > 0
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

    private

    def pending_events
      Xlib.XPending(to_native)
    end

    def next_event
      x_event = Xlib::XEvent.new
      Xlib.XNextEvent(to_native, x_event) # blocks
      Event.new(x_event)
    end

    def handle_event(event)
      handling_window_id = event.event || event.parent || event.window
      handling_window = Window.new(self, handling_window_id)
      handling_window.handle(event)
    end

    def screen_pointer(number)
      @struct[:screens] + number*Xlib::Screen.size
    end

    def screen(number)
      Screen.new(self, screen_pointer(number))
    end
  end
end