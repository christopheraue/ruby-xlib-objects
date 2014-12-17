describe XlibObj::Screen::Crtc do
  subject(:klass) { described_class.clone }
  subject(:instance) { klass.new(screen, :crtc_id) }

  let(:display) { instance_double(XlibObj::Display, to_native: :display_ptr) }
  let(:root_win) { instance_double(XlibObj::Window, to_native: :root_win_id) }
  let(:screen) { instance_double(XlibObj::Screen, display: display, root_window:
    root_win) }

  describe "#screen: Getting its screen" do
    subject { instance.screen }
    it { is_expected.to be screen }
  end

  describe "#id: Getting its Id" do
    subject { instance.id }
    it { is_expected.to be :crtc_id }
  end

  describe "#attribute: Getting one of its attributes" do
    subject { instance.attribute(:attribute_key) }

    let(:attributes) { { attribute_key: :attribute_value } }

    before { allow(Xlib).to receive(:XRRGetScreenResources) }
    before { allow(Xlib).to receive(:XRRGetCrtcInfo) }
    before { allow(Xlib::XRRCrtcInfo).to receive(:new).and_return(attributes) }
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

  describe "#outputs: Getting its outputs" do
    subject { instance.outputs }

    let(:outputs_ptr) { FFI::MemoryPointer.new :void }
    let(:output1_ptr) { FFI::MemoryPointer.new :void }
    let(:output2_ptr) { FFI::MemoryPointer.new :void }

    before { allow(instance).to receive(:attribute).with(:noutput).and_return(
      2) }
    before { allow(instance).to receive(:attribute).with(:outputs).and_return(
      outputs_ptr) }
    before { allow(outputs_ptr).to receive(:+).with(0).and_return(output1_ptr) }
    before { allow(outputs_ptr).to receive(:+).with(FFI.type_size(:RROutput)).
      and_return(output2_ptr) }
    before { allow(output1_ptr).to receive(:read_ulong).and_return(
      :output_id_1) }
    before { allow(output2_ptr).to receive(:read_ulong).and_return(
      :output_id_2) }
    before { allow(XlibObj::Screen::Crtc::Output).to receive(:new).with(
      instance, :output_id_1).and_return(:output1) }
    before { allow(XlibObj::Screen::Crtc::Output).to receive(:new).with(
      instance, :output_id_2).and_return(:output2) }

    it { is_expected.to eq [:output1, :output2] }
  end
end