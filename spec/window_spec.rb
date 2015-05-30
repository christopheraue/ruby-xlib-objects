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

    describe "#delete_property: Deletes one of its properties" do
      subject { instance.delete_property(:property_key) }

      let(:property) { instance_double(XlibObj::Window::Property) }

      before { allow(XlibObj::Window::Property).to receive(:new).with(instance,
          :property_key).and_return(property) }

      it { is_expected.to send_message(:delete).to(property) }
    end

    describe "#absolute_position: Getting is position relative to the root window" do
      subject { instance.absolute_position }

      let(:root_win) { instance_double(XlibObj::Window, to_native: :root_win_id) }

      before { allow(FFI::MemoryPointer).to receive(:new) }
      before { allow(FFI::MemoryPointer).to receive(:new).with(:int).
        and_return(instance_double(FFI::MemoryPointer, read_int: 0),
          instance_double(FFI::MemoryPointer, read_int: 1)) }
      before { allow(instance).to receive_message_chain(:screen, :root_window).and_return(root_win) }
      before { allow(Xlib).to receive(:XTranslateCoordinates) }

      it { is_expected.to eq(x: 0, y: 1) }
    end

    describe "#focused?: Checks if the window currently has the input focus" do
      subject { instance.focused? }

      before { allow(FFI::MemoryPointer).to receive(:new).with(:Window).and_return(window_ptr) }
      before { allow(FFI::MemoryPointer).to receive(:new).with(:int).and_return(:int_ptr) }
      before { allow(Xlib).to receive(:XGetInputFocus).with(:display_ptr, window_ptr, :int_ptr) }

      context "when the returned window id matches the id of the instance" do
        let(:window_ptr) { instance_double(FFI::MemoryPointer, read_int: instance.id) }
        it { is_expected.to be true }
      end

      context "when the returned window id does not match the id of the instance" do
        let(:window_ptr) { instance_double(FFI::MemoryPointer, read_int: :another_id) }
        it { is_expected.to be false }
      end
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

    describe "#on: Listens to an event" do
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

    describe "#off: Stops listening to an event" do
      before { allow(event_handler).to receive(:off) }

      it { is_expected.to be instance }

      context "when a callback is given" do
        subject { instance.off(:mask, :type, callback) }
        let(:callback) { Proc.new{} }
        it { is_expected.to send_message(:off).to(event_handler).with(:mask, :type, callback) }
      end

      context "when no callback is given" do
        subject { instance.off(:mask, :type) }
        it { is_expected.to send_message(:off).to(event_handler).with(:mask, :type, nil) }
      end
    end

    describe "#handle: Handles an event" do
      subject { instance.handle(:event) }

      before { allow(event_handler).to receive(:handle) }

      it { is_expected.to send_message(:handle).to(event_handler).with(:event) }
      it { is_expected.to be instance }
    end

    describe "#send_to_itself: Sends itself a client message" do
      subject { instance.send_to_itself(:type, :data, :subject) }

      let(:message) { instance_double(XlibObj::Event::ClientMessage) }

      before { allow(XlibObj::Event::ClientMessage).to receive(:new).
        with(:type, :data, :subject).and_return(message) }

      it { is_expected.to send_message(:send_to).to(message).with(instance) }
    end

    describe "#request_selection: Requests to be handed the current selection/clipboard content" do
      subject { instance.request_selection(:CLIPBOARD, target: :UTF8_STRING, property: :XSEL_DATA,
        &callback) }
      let(:callback) { Proc.new{} }

      before { allow(instance).to receive(:until_true).and_return(:event_handler) }
      let(:type_atom) { instance_double(XlibObj::Atom, to_native: :type_atom) }
      let(:format_atom) { instance_double(XlibObj::Atom, to_native: :format_atom) }
      let(:property_atom) { instance_double(XlibObj::Atom, to_native: :property_atom) }
      before { allow(XlibObj::Atom).to receive(:new).with(display, :CLIPBOARD).and_return(type_atom) }
      before { allow(XlibObj::Atom).to receive(:new).with(display, :UTF8_STRING).and_return(format_atom) }
      before { allow(XlibObj::Atom).to receive(:new).with(display, :XSEL_DATA).and_return(property_atom) }
      before { allow(Xlib).to receive(:XConvertSelection) }
      before { allow(Xlib).to receive(:XFlush) }

      it { is_expected.to send_message(:until_true).to(instance).with(:no_event, :selection_notify).
          with_block }
      it { is_expected.to send_message(:XConvertSelection).to(Xlib).with(:display_ptr, :type_atom,
        :format_atom, :property_atom, :win_id, Xlib::CurrentTime) }
      it { is_expected.to send_message(:XFlush).to(Xlib).with(:display_ptr) }
      it { is_expected.to be instance }

      context "when the clipboard content is ready" do
        before { allow(instance).to receive(:until_true).and_yield(event) }
        let(:event) { double(XlibObj::Event, selection: :selection_atom_id, target: :target_atom_id,
          property: :property_atom_id) }

        let(:selection_atom) { instance_double(XlibObj::Atom, name: :CLIPBOARD) }
        before { allow(XlibObj::Atom).to receive(:new).with(display, :selection_atom_id).
            and_return(selection_atom) }
        let(:target_atom) { instance_double(XlibObj::Atom, name: :UTF8_STRING) }
        before { allow(XlibObj::Atom).to receive(:new).with(display, :target_atom_id).
            and_return(target_atom) }
        before { allow(Xlib).to receive(:XGetSelectionOwner).with(:display_ptr, :selection_atom_id).
            and_return(:owner_id) }
        before { allow(XlibObj::Window).to receive(:new).with(display, :owner_id).
            and_return(:selection_owner) }
        before { allow(instance).to receive(:property).with(:property_atom_id).
            and_return(:clipboard_content) }
        before { allow(instance).to receive(:delete_property) }
        before { allow(instance).to receive(:off) }

        it { is_expected.to send_message(:call).to(callback).with(:clipboard_content, :CLIPBOARD,
            :selection_owner) }

        context "when the reported type does not match the requested type" do
          before { allow(selection_atom).to receive(:name).and_return(:PRIMARY) }
          it { is_expected.not_to send_message(:call).to(callback) }
        end

        context "when the reported format does not match the requested format" do
          before { allow(target_atom).to receive(:name).and_return(:STRING) }
          it { is_expected.not_to send_message(:call).to(callback) }
        end

        context "when the reported property is None" do
          before { allow(event).to receive(:property).and_return(Xlib::None) }
          it { is_expected.to send_message(:call).to(callback).with(nil, any_args) }
        end
      end
    end

    describe "#set_selection: Sets the request handler for a given selection" do
      subject { instance.set_selection(:CLIPBOARD, targets: [:UTF8_STRING], &callback) }
      let(:callback) { Proc.new{ 'selection' } }

      let(:type_atom) { instance_double(XlibObj::Atom, to_native: :type_atom_id) }
      before { allow(XlibObj::Atom).to receive(:new).with(display, :CLIPBOARD).and_return(type_atom) }
      before { allow(instance).to receive_messages(on: :request_handler, until_true: :clear_handler) }
      before { allow(Xlib).to receive(:XSetSelectionOwner) }

      it { is_expected.to send_message(:XSetSelectionOwner).to(Xlib).with(:display_ptr, :type_atom_id,
          :win_id, Xlib::CurrentTime) }
      it { is_expected.to send_message(:on).to(instance).with(:no_event, :selection_request).
          with_block }
      it { is_expected.to send_message(:until_true).to(instance).with(:no_event, :selection_clear).
          with_block }
      it { is_expected.to be instance }

      context "when a request comes in" do
        before { allow(instance).to receive(:on).with(:no_event, :selection_request).and_yield(event) }
        let(:event) { double(XlibObj::Event, selection: :selection_atom_id, target: :target_atom_id,
          property: :property_atom_id, requestor: :requestor_id) }

        let(:selection_atom) { instance_double(XlibObj::Atom, name: :CLIPBOARD) }
        let(:target_atom) { instance_double(XlibObj::Atom, name: :UTF8_STRING) }
        let(:requestor) { instance_double(XlibObj::Window, set_property: nil) }
        let(:selection_notify) { instance_double(XlibObj::Event::SelectionNotify, send_to: true) }
        before { allow(XlibObj::Atom).to receive(:new).with(display, :selection_atom_id).
            and_return(selection_atom) }
        before { allow(XlibObj::Atom).to receive(:new).with(display, :target_atom_id).
            and_return(target_atom) }
        before { allow(XlibObj::Window).to receive(:new).with(display, :requestor_id).
            and_return(requestor) }
        before { allow(XlibObj::Event::SelectionNotify).to receive(:new).with(type: :selection_atom_id,
            target: :target_atom_id, property: :property_atom_id).and_return(selection_notify) }

        context "when the reported type does not match the requested type" do
          before { allow(selection_atom).to receive(:name).and_return(:PRIMARY) }
          it { is_expected.not_to send_message(:send_to).to(selection_notify) }
        end

        context "when requesting an unsupported target" do
          before { allow(target_atom).to receive(:name).and_return(:UNSUPPORTED) }
          before { allow(XlibObj::Event::SelectionNotify).to receive(:new).with(type: :selection_atom_id,
              target: :target_atom_id, property: Xlib::None).and_return(selection_notify) }
          it { is_expected.to send_message(:send_to).to(selection_notify).with(requestor) }
        end

        context "when requesting target :TARGETS" do
          before { allow(target_atom).to receive(:name).and_return(:TARGETS) }
          before { allow(XlibObj::Atom).to receive(:new).with(display, :UTF8_STRING).and_return(:utf8_string_atom) }
          before { allow(XlibObj::Atom).to receive(:new).with(display, :TARGETS).and_return(:targets_atom) }
          it { is_expected.to send_message(:set_property).to(requestor).with(:property_atom_id,
              [:utf8_string_atom, :targets_atom]) }
          it { is_expected.to send_message(:send_to).to(selection_notify).with(requestor) }
        end

        context "when requesting a supported target" do
          before { allow(target_atom).to receive(:name).and_return(:UTF8_STRING) }
          it { is_expected.to send_message(:call).to(callback).with(:UTF8_STRING).and_return('selection') }
          it { is_expected.to send_message(:send_to).to(selection_notify).with(requestor) }
        end
      end
    end

    describe "#create_window: Creates a simple sub window" do
      it "needs to be spec'd"
    end

    describe "#destroy: Destroys it" do
      subject { instance.destroy }
      let(:event_handler) { XlibObj::Window::EventHandler.singleton(display, :win_id) }

      before { allow(Xlib).to receive(:XDestroyWindow) }

      it { is_expected.to send_message(:destroy).to(event_handler) }
      it { is_expected.to send_message(:XDestroyWindow).to(Xlib).with(:display_ptr, :win_id) }
    end
  end
end