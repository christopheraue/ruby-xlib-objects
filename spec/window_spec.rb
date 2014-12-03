describe XlibObj::Window do
  subject(:klass) { described_class.clone }
  subject(:instance) { klass.new(display, :win_id) }

  let(:display) { instance_double(XlibObj::Display, to_native: :display_ptr) }
end