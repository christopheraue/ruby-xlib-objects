module XlibObj
  class Extension::XI < Extension
    private

    def select_input(display, window, bit_mask)
      Xlib::XI.select_events(display, display.input_devices.select(&:slave?), window, bit_mask)
    end
  end
end