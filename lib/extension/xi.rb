module XlibObj
  class Extension::XI < Extension
    private

    def native_interface
      Xlib::XI
    end
  end
end