describe XlibObj::Window::EventHandler do
  subject(:klass) { described_class.clone }
  subject(:instance) { klass.new(display, :win_id) }

  let(:display) { instance_double(XlibObj::Display, to_native: :display_ptr) }

  describe "The class" do
    describe ".singleton: Create a new instance only once" do
      subject { klass.singleton(display, :win_id) }

      context 'when called the first time for a specific window' do
        it { is_expected.to be_a klass }
      end

      context 'when called a second time for a specific window' do
        let(:event_handler) { klass.singleton(display, :win_id) }
        before { event_handler }
        it { is_expected.to be event_handler }
      end
    end

    describe ".remove: Removes a handler from its registry" do
      subject { klass.remove(display, :win_id) }

      context "when a handler is registered" do
        let(:handler) { klass.singleton(display, :win_id) }
        it { is_expected.to be handler }

        context "when the handler is tried to be removed again" do
          before { subject }
          it { is_expected.to be nil }
        end
      end

      context "when no handler has been registered" do
        it { is_expected.to be nil }
      end
    end
  end

  describe "The instance" do
    before { allow(Xlib).to receive(:XSelectInput) }
    before { allow(Xlib).to receive(:XRRSelectInput) }
    before { allow(Xlib).to receive(:XFlush) }

    describe "#on: Attaching a callback to an event mask and type" do
      subject { instance.on(mask, type, &callback) }

      let(:callback) { Proc.new{} }

      context "when the event has not been registered before" do
        context "when a standard X event and mask is given (e.g. property notify)" do
          let(:mask) { :property_change }
          let(:type) { :property_notify }

          it "selects the mask" do
            is_expected.to send_message(:XSelectInput).to(Xlib).with(
            :display_ptr, :win_id, Xlib::PropertyChangeMask)
          end
          it { is_expected.to send_message(:XFlush).to(Xlib).with(:display_ptr) }
          it { is_expected.to be callback }
        end

        context "when a randr event and mask is given (e.g. screen change notify)" do
          let(:mask) { :screen_change_notify }
          let(:type) { :screen_change_notify }

          it "selects the mask" do
            is_expected.to send_message(:XRRSelectInput).to(Xlib).with(
              :display_ptr, :win_id, Xlib::RRScreenChangeNotifyMask)
          end
          it { is_expected.to send_message(:XFlush).to(Xlib).with(:display_ptr) }
          it { is_expected.to be callback }
        end
      end

      context "when the same event has been registered before" do
        before { instance.on(mask, type, &callback) }

        context "when a standard X event and mask is given (e.g. property notify)" do
          let(:mask) { :property_change }
          let(:type) { :property_notify }

          it "does not select the mask again" do
            is_expected.not_to send_message(:XSelectInput).to(Xlib).with(
            :display_ptr, :win_id, Xlib::PropertyChangeMask).twice
          end
          it { is_expected.not_to send_message(:XFlush).to(Xlib).twice }
          it { is_expected.to be callback }
        end

        context "when a randr event and mask is given (e.g. screen change notify)" do
          let(:mask) { :screen_change_notify }
          let(:type) { :screen_change_notify }

          it "does not select the mask again" do
            is_expected.not_to send_message(:XRRSelectInput).to(Xlib).with(
              :display_ptr, :win_id, Xlib::RRScreenChangeNotifyMask).twice
          end
          it { is_expected.not_to send_message(:XFlush).to(Xlib).twice }
          it { is_expected.to be callback }
        end
      end

      context "when a standard X event has already been registered (e.g. configure notify)" do
        before { instance.on(:structure_notify, :configure_notify, &callback) }

        context "when a second, different standard X event and mask is given (e.g. property notify)" do
          let(:mask) { :property_change }
          let(:type) { :property_notify }

          it "selects both masks" do
            is_expected.to send_message(:XSelectInput).to(Xlib).with(
              :display_ptr, :win_id, Xlib::PropertyChangeMask |
              Xlib::StructureNotifyMask)
          end
          it { is_expected.to send_message(:XFlush).to(Xlib).with(:display_ptr).
            twice }
          it { is_expected.to be callback }
        end
      end

      context "when a randr event has already been registered (e.g. output change notify)" do
        before { instance.on(:output_change_notify, :notify, &callback) }

        context "when a second, different standard randr event and mask is given" do
          let(:mask) { :screen_change_notify }
          let(:type) { :screen_change_notify }

          it "selects both randr masks" do
            is_expected.to send_message(:XRRSelectInput).to(Xlib).with(
              :display_ptr, :win_id, Xlib::RRScreenChangeNotifyMask |
              Xlib::RROutputChangeNotifyMask)
          end
          it { is_expected.to send_message(:XFlush).to(Xlib).with(:display_ptr).
            twice }
          it { is_expected.to be callback }
        end
      end

      context "when an event mask is given that neither X nor randr handles" do
        let(:mask) { :invalid }
        let(:type) { :property_notify }
        it { is_expected.to raise_error }
      end

      context "when an event type is given that neither X nor randr handles" do
        let(:mask) { :property_change }
        let(:type) { :invalid }
        it { is_expected.to raise_error }
      end
    end

    describe "#off: Detaching a callback from an event mask and type" do
      subject { instance.off(mask, type, callback) }

      let(:callback) { Proc.new{} }

      context "when the event has not been registered before" do
        context "when a standard X event and mask is given (e.g. property notify)" do
          let(:mask) { :property_change }
          let(:type) { :property_notify }

          it { is_expected.not_to send_message(:XSelectInput).to(Xlib) }
          it { is_expected.not_to send_message(:XFlush).to(Xlib) }
        end

        context "when a randr event and mask is given (e.g. screen change notify)" do
          let(:mask) { :screen_change_notify }
          let(:type) { :screen_change_notify }

          it { is_expected.not_to send_message(:XRRSelectInput).to(Xlib) }
          it { is_expected.not_to send_message(:XFlush).to(Xlib) }
        end
      end

      context "when the event has been registered before" do
        before { instance.on(mask, type, &callback) }

        context "when a standard X event and mask is given (e.g. property notify)" do
          let(:mask) { :property_change }
          let(:type) { :property_notify }

          it { is_expected.to send_message(:XSelectInput).to(Xlib).with(
            :display_ptr, :win_id, 0) }
          it { is_expected.to send_message(:XFlush).to(Xlib).with(
            :display_ptr).twice }
        end

        context "when a randr event and mask is given (e.g. screen change notify)" do
          let(:mask) { :screen_change_notify }
          let(:type) { :screen_change_notify }

          it { is_expected.to send_message(:XRRSelectInput).to(Xlib).with(
            :display_ptr, :win_id, 0) }
          it { is_expected.to send_message(:XFlush).to(Xlib).with(
            :display_ptr).twice }
        end
      end

      context "when a second, different event has been registered" do
        context "when a standard X event and mask is given (e.g. property notify)" do
          let(:mask) { :property_change }
          let(:type) { :property_notify }

          before { instance.on(:structure_notify, :configure_notify, &callback) }

          it "leaves the mask of the second event intact" do
            is_expected.to send_message(:XSelectInput).to(Xlib).with(
              :display_ptr, :win_id, Xlib::StructureNotifyMask)
          end
          it { is_expected.to send_message(:XFlush).to(Xlib).with(:display_ptr) }
        end

        context "when a randr event and mask is given (e.g. screen change notify)" do
          let(:mask) { :screen_change_notify }
          let(:type) { :screen_change_notify }

          before { instance.on(:output_change_notify, :notify, &callback) }

          it "leaves the mask of the second event intact" do
            is_expected.to send_message(:XRRSelectInput).to(Xlib).with(
              :display_ptr, :win_id, Xlib::RROutputChangeNotifyMask)
          end
          it { is_expected.to send_message(:XFlush).to(Xlib).with(:display_ptr) }
        end
      end

      context "when the mask is used by another event" do
        before { instance.on(mask, :map_notify, &callback) }

        context "when a standard X event and mask is given (e.g. property notify)" do
          let(:mask) { :property_change }
          let(:type) { :property_notify }

          it "does not deselect the mask" do
            is_expected.not_to send_message(:XSelectInput).to(Xlib).twice
          end
          it { is_expected.not_to send_message(:XFlush).to(Xlib).with(
            :display_ptr).twice }
        end

        context "when a randr event and mask is given (e.g. screen change notify)" do
          let(:mask) { :screen_change_notify }
          let(:type) { :screen_change_notify }

          it "does not deselect the mask" do
            is_expected.not_to send_message(:XRRSelectInput).to(Xlib).twice
          end
          it { is_expected.not_to send_message(:XFlush).to(Xlib).with(
            :display_ptr).twice }
        end
      end
    end

    describe "#handle: Handling an event" do
      subject { instance.handle(event) }

      let(:event) { instance_double(XlibObj::Event, name: event_name) }
      let(:event_name) { :any }

      context "when such an event has not been registered" do
        it { is_expected.to be false }
      end

      context "when such events have been registered" do
        before { instance.on(:property_change, :property_notify, &callback1) }
        before { instance.on(:property_change, :property_notify, &callback2) }
        let(:event_name) { :property_notify }
        let(:callback1) { Proc.new{} }
        let(:callback2) { Proc.new{} }
        it { is_expected.to send_message(:call).to(callback1).with(event) }
        it { is_expected.to send_message(:call).to(callback2).with(event) }
        it { is_expected.to be true }
      end
    end

    describe "#destroy: Destroys it" do
      subject { instance.destroy }
      it { is_expected.to send_message(:remove).to(klass).with(display, :win_id) }
    end
  end
end