FactoryGirl.define do
  factory :screen, class: CappX11::Screen do
    initialize_with do
      display = build(:display)
      display.screens.first
    end
  end
end