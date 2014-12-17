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

    let(:attributes) { { attribute_key: :attribute_value } }

    before { allow(Xlib).to receive(:XRRGetScreenResources) }
    before { allow(Xlib).to receive(:XRRGetOutputInfo) }
    before { allow(Xlib::XRROutputInfo).to receive(:new).and_return(attributes) }
    before { allow(Xlib).to receive(:XRRFreeScreenResources) }

    context "when the attribute is not a member of the struct" do
      before { allow(attributes).to receive_message_chain(:layout, :members,
        :include?).with(:attribute_key).and_return(false) }
      it { is_expected.to be nil }
    end

    context "when the attribute is a member of the struct" do
      before { allow(attributes).to receive_message_chain(:layout, :members,
        :include?).with(:attribute_key).and_return(true) }
      it { is_expected.to be :attribute_value }
      it { is_expected.to send_message(:XRRFreeScreenResources).to(Xlib) }
    end
  end

  describe "#method_missing: Getting an attribute" do
    subject { instance.attribute_key }

    before { allow(instance).to receive(:attribute).and_return(
      :attribute_value) }

    it { is_expected.to be :attribute_value }
  end
end