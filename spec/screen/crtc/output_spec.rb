describe XlibObj::Screen::Crtc::Output do
  subject(:klass) { described_class.clone }
  subject(:instance) { klass.new(crtc, :output_id) }

  let(:display) { instance_double(XlibObj::Display, to_native: :display_ptr) }
  let(:root_win) { instance_double(XlibObj::Window, to_native: :root_win_id) }
  let(:screen) { instance_double(XlibObj::Screen, display: display, root_window:
    root_win) }
  let(:crtc) { instance_double(XlibObj::Screen::Crtc, screen: screen) }

  describe "#crtc: Getting its crtc" do
    subject { instance.crtc }
    it { is_expected.to be crtc }
  end

  describe "#id: Getting its Id" do
    subject { instance.id }
    it { is_expected.to be :output_id }
  end

  describe "#attribute: Getting one of its attributes" do
    subject { instance.attribute(:attribute_key) }

    before { allow(Xlib).to receive(:XRRGetScreenResources) }
    before { allow(Xlib).to receive(:XRRGetOutputInfo) }
    before { allow(Xlib::XRROutputInfo).to receive(:new).and_return(
      attribute_key: :attribute_value) }
    before { allow(Xlib).to receive(:XRRFreeScreenResources) }
    before { allow(Xlib).to receive(:XRRFreeOutputInfo) }

    it { is_expected.to be :attribute_value }
  end

  describe "#method_missing: Getting an attribute" do
    subject { instance.attribute_key }

    before { allow(instance).to receive(:attribute).and_return(
      :attribute_value) }

    it { is_expected.to be :attribute_value }
  end
end