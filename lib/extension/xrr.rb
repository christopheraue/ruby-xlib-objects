module XlibObj
  class Extension::XRR < Extension
    def last_event
      first_event + Xlib::RRNumberEvents-1
    end

    def last_error
      first_error + Xlib::RRNumberErrors-1
    end
  end
end