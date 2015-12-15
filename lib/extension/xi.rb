module XlibObj
  class Extension::XI < Extension
    private

    def select_input(display, window, bit_mask)
      Xlib::XI.select_events(display, Xlib::XIAllDevices, window, bit_mask)
    end
  end
end