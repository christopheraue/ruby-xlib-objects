describe XlibObj::Display do
  subject(:klass) { described_class.clone }
  subject(:instance) { klass.new(:display_name) }

  let(:display_ptr) { double(null?: false) }
  let(:display_struct) { instance_double(Xlib::Display, pointer: display_ptr) }

  before { allow(Xlib).to receive(:XOpenDisplay).and_return(display_ptr) }
  before { allow(Xlib::Display).to receive(:new).with(display_ptr).
    and_return(display_struct) }

  describe 'getting its native representation' do
    subject { instance.to_native }
    it { is_expected.to be(display_ptr) }
  end
end