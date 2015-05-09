describe XlibObj::Window do
  subject(:klass) { described_class.clone }
  subject(:instance) { klass.new(display, :win_id) }

  let(:display) { instance_double(XlibObj::Display, to_native: :display_ptr) }
  let(:screen) { instance_double(XlibObj::Screen) }
  let(:event_handler) { instance_double(XlibObj::Window::EventHandler) }

  before { allow(XlibObj::Window::EventHandler).to receive(:singleton).
    with(display, :win_id).and_return(event_handler) }

  describe "The instance" do
    describe "#display: Getting its display" do
      subject { instance.display }
      it { is_expected.to be display }
    end

    describe "#to_native: Getting its window id" do
      subject { instance.to_native }
      it { is_expected.to be :win_id }
    end

    describe "#id: Getting its window id" do
      subject { instance.id }
      it { is_expected.to be :win_id }
    end

    describe "#attribute: Getting one of its attribute values" do
      subject { instance.attribute(:attribute_key) }

      let(:attributes) { instance_double(Xlib::WindowAttributes, pointer:
        :attributes_ptr)}

      before { allow(Xlib::WindowAttributes).to receive(:new).
        and_return(attributes) }
      before { allow(Xlib).to receive(:XGetWindowAttributes).with(:display_ptr,
        :win_id, :attributes_ptr) }
      before { allow(attributes).to receive(:[]).with(:attribute_key).
        and_return(:attribute_value)}

      it { is_expected.to be :attribute_value }

      context "when the attribute does not exist for windows" do
        before { allow(Xlib).to receive(:XGetWindowAttributes).and_raise }
        it { is_expected.to be nil }
      end
    end

    describe "#method_missing: Getting an attribute" do
      subject { instance.attribute_key }
      before { allow(instance).to receive(:attribute).with(:attribute_key).
        and_return(:attribute_value) }
      it { is_expected.to be :attribute_value }
    end

    describe "#screen: Getting its screen" do
      subject { instance.screen }
      before { allow(instance).to receive(:attribute).with(:screen).
        and_return(:screen_ptr) }
      before { allow(XlibObj::Screen).to receive(:new).with(display,
        :screen_ptr).and_return(:screen) }
      it { is_expected.to be :screen }
    end

    describe "#property: Getting one of its property values" do
      subject { instance.property(:property_key) }

      let(:property) { instance_double(XlibObj::Window::Property, get:
        :property_value) }

      before { allow(XlibObj::Window::Property).to receive(:new).with(instance,
        :property_key).and_return(property) }

      it { is_expected.to be :property_value }
    end

    describe "#set_property: Setting one of its properties" do
      subject { instance.set_property(:property_key, :new_value) }

      let(:property) { instance_double(XlibObj::Window::Property) }

      before { allow(XlibObj::Window::Property).to receive(:new).with(instance,
        :property_key).and_return(property) }

      it { is_expected.to send_message(:set).to(property).with(:new_value) }
    end

    describe "#absolute_position: Getting is position relative to the root
      window" do
      subject { instance.absolute_position }

      let(:root_win) { instance_double(XlibObj::Window, to_native:
        :root_win_id) }

      before { allow(FFI::MemoryPointer).to receive(:new) }
      before { allow(FFI::MemoryPointer).to receive(:new).with(:int).
        and_return(instance_double(FFI::MemoryPointer, read_int: 0),
          instance_double(FFI::MemoryPointer, read_int: 1)) }
      before { allow(instance).to receive_message_chain(:screen, :root_window).
        and_return(root_win) }
      before { allow(Xlib).to receive(:XTranslateCoordinates) }

      it { is_expected.to eq(x: 0, y: 1) }
    end

    describe "#move_resize: Moving and/or resizing the window" do
      subject { instance.move_resize(:x, :y, :width, :height) }

      before { allow(Xlib).to receive(:XMoveResizeWindow) }
      before { allow(Xlib).to receive(:XFlush) }

      it { is_expected.to send_message(:XMoveResizeWindow).to(Xlib).
        with(:display_ptr, :win_id, :x, :y, :width, :height) }
      it { is_expected.to send_message(:XFlush).to(Xlib).with(:display_ptr) }
      it { is_expected.to be(instance) }
    end

    describe "#map: Mapping the window" do
      subject { instance.map }

      before { allow(Xlib).to receive(:XMapWindow) }
      before { allow(Xlib).to receive(:XFlush) }

      it { is_expected.to send_message(:XMapWindow).to(Xlib).with(:display_ptr,
        :win_id) }
      it { is_expected.to send_message(:XFlush).to(Xlib).with(:display_ptr) }
      it { is_expected.to be(instance) }
    end

    describe "#unmap: Unmapping the window" do
      subject { instance.unmap }

      before { allow(Xlib).to receive(:XUnmapWindow) }
      before { allow(Xlib).to receive(:XFlush) }

      it { is_expected.to send_message(:XUnmapWindow).to(Xlib).with(
        :display_ptr, :win_id) }
      it { is_expected.to send_message(:XFlush).to(Xlib).with(:display_ptr) }
      it { is_expected.to be(instance) }
    end

    describe "#iconify: Iconifying the window" do
      subject { instance.iconify }

      before { allow(Xlib).to receive(:XIconifyWindow) }
      before { allow(Xlib).to receive(:XFlush) }
      before { allow(instance).to receive_message_chain(:screen, :number).
        and_return(:screen_number) }

      it { is_expected.to send_message(:XIconifyWindow).to(Xlib).with(
        :display_ptr, :win_id, :screen_number) }
      it { is_expected.to send_message(:XFlush).to(Xlib).with(:display_ptr) }
      it { is_expected.to be(instance) }
    end

    describe "#raise: Raising the window" do
      subject { instance.raise }

      before { allow(Xlib).to receive(:XRaiseWindow) }
      before { allow(Xlib).to receive(:XFlush) }

      it { is_expected.to send_message(:XRaiseWindow).to(Xlib).with(
          :display_ptr, :win_id) }
      it { is_expected.to send_message(:XFlush).to(Xlib).with(:display_ptr) }
      it { is_expected.to be(instance) }
    end

    describe "#focus: Focuses the window" do
      subject { instance.focus }

      before { allow(Xlib).to receive(:XSetInputFocus) }
      before { allow(Xlib).to receive(:XFlush) }

      it { is_expected.to send_message(:XSetInputFocus).to(Xlib).with(:display_ptr, :win_id,
          Xlib::RevertToParent, Xlib::CurrentTime) }
      it { is_expected.to send_message(:XFlush).to(Xlib).with(:display_ptr) }
      it { is_expected.to be(instance) }
    end

    describe "#on: Listening to an event" do
      subject { instance.on(:mask, :type, &callback) }

      let(:callback) { Proc.new{} }

      before { allow(event_handler).to receive(:on).and_return(callback) }

      it { is_expected.to send_message(:on).to(event_handler).with(:mask, :type).
        with_block(callback) }
      it 'returns the callback so it can be saved to detach it later with
          #off' do
        is_expected.to be callback
      end
    end

    describe "#off: Stopping listening to an event" do
      subject { instance.off(:mask, :type, callback) }

      let(:callback) { Proc.new{} }

      before { allow(event_handler).to receive(:off) }

      it { is_expected.to send_message(:off).to(event_handler).with(:mask,
        :type, callback) }
      it { is_expected.to be instance }
    end

    describe "#handle: Handling an event" do
      subject { instance.handle(:event) }

      before { allow(event_handler).to receive(:handle) }

      it { is_expected.to send_message(:handle).to(event_handler).with(:event) }
      it { is_expected.to be instance }
    end

    describe "#send_to_itself: Sending itself a client message" do
      subject { instance.send_to_itself(:type, :data, :subject) }

      let(:message) { instance_double(XlibObj::Event::ClientMessage) }

      before { allow(XlibObj::Event::ClientMessage).to receive(:new).
        with(:type, :data, :subject).and_return(message) }

      it { is_expected.to send_message(:send_to).to(message).with(instance) }
    end
  end
end