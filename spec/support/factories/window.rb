FactoryGirl.define do
  factory :window, class: CappX11::Window do
    initialize_with do
      screen = build(:screen)
      screen.root_window
    end
  end
end