FactoryGirl.define do
  factory :display, class: Xlib::Display do
    initialize_with { Xlib::Display.open(':0') }
  end

  factory :display_struct, class: Xlib::Capi::Display do
    initialize_with do
      display_ptr = Xlib::Capi.XOpenDisplay(':0')
      Xlib::Capi::Display.new(display_ptr)
    end
  end
end