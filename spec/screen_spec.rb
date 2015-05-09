describe XlibObj::Screen do
  subject(:klass) { described_class.clone }
  subject(:instance) { klass.new(display, :screen_ptr) }

  let(:display) { instance_double(XlibObj::Display, to_native: :display_ptr) }
  let(:screen_struct) { instance_double(Xlib::Screen, pointer: :screen_ptr) }

  before { allow(Xlib::Screen).to receive(:new).with(:screen_ptr).
    and_return(screen_struct) }

  describe "The instance" do
    describe "#display: Getting its display" do
      subject { instance.display }
      it { is_expected.to be display }
    end

    describe "#attribute: Getting one of its attributes from its struct" do
      subject { instance.attribute(:attribute_key) }

      before { allow(screen_struct).to receive(:[]).with(:attribute_key).
        and_return(:attribute_value) }

      context "when the attribute is not a member of the struct" do
        before { allow(screen_struct).to receive_message_chain(:layout, :members,
          :include?).with(:attribute_key).and_return(false) }
        it { is_expected.to be nil }
      end

      context "when the attribute is a member of the struct" do
        before { allow(screen_struct).to receive_message_chain(:layout, :members,
          :include?).with(:attribute_key).and_return(true) }
        it { is_expected.to be :attribute_value }
      end
    end

    describe "#method_missing: Getting an attribute" do
      subject { instance.attribute_key }
      before { allow(instance).to receive(:attribute).with(:attribute_key).
        and_return(:attribute_value) }
      it { is_expected.to be :attribute_value }
    end

    describe "#to_native: Getting its native representation" do
      subject { instance.to_native }
      it { is_expected.to be :screen_ptr }
    end

    describe "#number: Getting the screen's number" do
      subject { instance.number }
      before { allow(Xlib).to receive(:XScreenNumberOfScreen).with(:screen_ptr).
        and_return(:screen_number) }
      it { is_expected.to be :screen_number }
    end

    describe "#root_window: Getting its root window" do
      subject { instance.root_window }
      before { allow(Xlib).to receive(:XRootWindowOfScreen).with(:screen_ptr).
        and_return(:win_id) }
      before { allow(XlibObj::Window).to receive(:new).with(display, :win_id).
        and_return(:root_window) }
      it { is_expected.to be :root_window}
    end

    describe "#focused_window: Gets the window on it that is focused" do
      subject { instance.focused_window }

      before { allow(FFI::MemoryPointer).to receive(:new).and_return(instance_double(FFI::MemoryPointer))}

      context "when there is no focused window" do
        before { allow(Xlib).to receive(:XGetInputFocus) do |display_ptr, window_ptr|
          allow(window_ptr).to receive(:read_int).and_return(Xlib::None)
        end }
        it { is_expected.to be nil }
      end

      context "when the focused window is the one under the pointer" do
        before { allow(Xlib).to receive(:XGetInputFocus) do |display_ptr, window_ptr|
          allow(window_ptr).to receive(:read_int).and_return(Xlib::PointerRoot)
        end }
        before { allow(instance).to receive(:root_window).and_return(:root_window) }
        it { is_expected.to be :root_window }
      end

      context "when the focused window is the one under the pointer" do
        before { allow(Xlib).to receive(:XGetInputFocus) do |display_ptr, window_ptr|
          allow(window_ptr).to receive(:read_int).and_return(1234)
        end }
        before { allow(XlibObj::Window).to receive(:new).with(display, 1234).and_return(:window) }
        it { is_expected.to be :window }
      end
    end

    describe "#crtcs: Getting its CRT controllers" do
      subject { instance.crtcs }

      let(:screen_resources) { instance_double(Xlib::XRRScreenResources) }
      let(:crtcs_pointer) { 1000000 }
      let(:crtc_id_size) { FFI.type_size(:RRCrtc) }

      before { allow(instance).to receive(:resources).
        and_return(screen_resources) }
      before { allow(screen_resources).to receive(:[]).with(:ncrtc).
        and_return(2) }
      before { allow(screen_resources).to receive(:[]).with(:crtcs).
        and_return(1000000) } #crtc ids pointer address
      before { allow(instance).to receive(:read_item).with(crtcs_pointer,
        0, crtc_id_size).and_return(0) }
      before { allow(instance).to receive(:read_item).with(crtcs_pointer,
        1, crtc_id_size).and_return(1) }
      before { allow(XlibObj::Screen::Crtc).to receive(:new).with(instance, 0).
        and_return(:crtc0) }
      before { allow(XlibObj::Screen::Crtc).to receive(:new).with(instance, 1).
        and_return(:crtc1) }

      it { is_expected.to eq [:crtc0, :crtc1] }
    end
  end
end