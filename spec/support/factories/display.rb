FactoryGirl.define do
  factory :display, class: CappX11::Display do
    initialize_with { CappX11::Display.open(':0') }
  end

  factory :display_struct, class: X11::Xlib::Display do
    initialize_with do
      display_ptr = X11::Xlib.XOpenDisplay(':0')
      X11::Xlib::Display.new(display_ptr)
    end
  end
end