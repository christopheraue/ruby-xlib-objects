#
# Copyright (c) 2015 Christopher Aue <mail@christopheraue.net>
#
# This file is part of the ruby xlib-objects gem. It is subject to the license
# terms in the LICENSE file found in the top-level directory of this
# distribution and at http://github.com/christopheraue/ruby-xlib-objects.
#

module XlibObj
  class Event
    class SelectionNotify
      def initialize(type:, target:, property:)
        @type, @target, @property = type, target, property
      end

      def send_to(receiver)
        Xlib.XSendEvent(receiver.display.to_native, receiver.to_native, false, 0, event(receiver))
        Xlib.XFlush(receiver.display.to_native)
      end

      private

      def event(receiver)
        event = Xlib::XEvent.new
        event[:xselection][:type]      = Xlib::SelectionNotify
        event[:xselection][:requestor] = receiver.to_native
        event[:xselection][:selection] = Atom.new(receiver.display, @type).to_native
        event[:xselection][:target]    = Atom.new(receiver.display, @target).to_native
        event[:xselection][:property]  = Atom.new(receiver.display, @property).to_native
        event[:xselection][:time]      = Xlib::CurrentTime
        event.pointer
      end
    end
  end
end