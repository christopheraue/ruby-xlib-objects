FactoryGirl.define do
  factory :sub_screen, class: CappX11::SubScreen do
    initialize_with do
      screen = build(:screen)
      screen.sub_screens.first
    end
  end
end