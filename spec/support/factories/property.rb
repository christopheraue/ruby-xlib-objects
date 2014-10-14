FactoryGirl.define do
  factory :property, class: CappX11::Window::Property do
    initialize_with do
      new(build(:window), {
        pointer: FFI::MemoryPointer.new(:pointer),
        name: 'prop_name',
        value: 'prop_value'
      })
    end
  end
end