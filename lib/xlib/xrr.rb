module Xlib
  module XRR
    class << self
      def select_input(display, window, mask)
        Xlib.XRRSelectInput(display.to_native, window.to_native, mask)
        Xlib::X.flush(display)
      end
    end
  end
end