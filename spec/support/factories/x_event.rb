FactoryGirl.define do
  factory :x_event, class: X11::Xlib::XEvent do
    ignore do
      window build(:window)
    end

    initialize_with do
      x_event = X11::Xlib::XEvent.new
      x_event[:type] = 28 #property notify
      x_property_event = X11::Xlib::XPropertyEvent.new x_event.pointer
      x_property_event[:type] = 28
      x_property_event[:serial] = 0
      x_property_event[:send_event] = false
      x_property_event[:display] = window.display.to_native.read_pointer
      x_property_event[:window] = window.to_native
      x_property_event[:atom] = 39
      x_property_event[:time] = 1412860400
      x_property_event[:state] = X11::Xlib::PROPERTY_NEW_VALUE
      x_event
    end
  end
end