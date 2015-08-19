#
# Copyright (c) 2014 Christopher Aue <mail@christopheraue.net>
#
# This file is part of the ruby xlib-objects gem. It is subject to the license
# terms in the LICENSE file found in the top-level directory of this
# distribution and at http://github.com/christopheraue/ruby-xlib-objects.
#

module XlibObj
  class Event
    class ClientMessage
      def initialize(type=nil, data=nil, subject=nil)
        self.type = type
        self.data = data
        self.subject = subject
      end

      attr_writer :subject, :data, :type

      def send_to(receiver)
        raise "The client message needs a type at least." unless @type
        @receiver = receiver
        Xlib.XSendEvent(@receiver.display.to_native, @receiver.to_native, false,
          Xlib::SubstructureNotifyMask | Xlib::SubstructureRedirectMask, to_native)
        @receiver.display.flush
      end

      private

      def to_native
        event = Xlib::XEvent.new
        event[:xclient][:type]         = Xlib::ClientMessage
        event[:xclient][:message_type] = message_type
        event[:xclient][:window]       = (@subject || @receiver).to_native

        if @data
          event[:xclient][:format] = format
          @data.each_with_index do |item, idx|
            event[:xclient][:data][data_member][idx] = item
          end
        end

        event.pointer
      end

      def message_type
        Atom.new(@receiver.display, @type).to_native
      end

      def format
        160/@data.size
      end

      def data_member
        case @data.size
        when 5  then :l
        when 10 then :s
        else :b
        end
      end
    end
  end
end