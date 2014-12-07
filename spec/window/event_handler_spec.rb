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
  end

  describe "The instance" do
    before { allow(Xlib).to receive(:XSelectInput) }
    before { allow(Xlib).to receive(:XRRSelectInput) }
    before { allow(Xlib).to receive(:XFlush) }

    describe ".on: Attaching a callback to an event mask and type" do
      subject { instance.on(mask, type, &callback) }

      let(:callback) { Proc.new{} }

      context "when a standard X event and mask is given (e.g. property
        notify)" do
        let(:mask) { :property_change }
        let(:type) { :property_notify }

        it "selects the mask" do
          is_expected.to send_message(:XSelectInput).to(Xlib).with(
          :display_ptr, :win_id, Xlib::PropertyChangeMask)
        end
        it { is_expected.to send_message(:XFlush).to(Xlib).with(:display_ptr) }
        it { is_expected.to be callback }

        context "when a second, different standard X event and mask is given" do
          before { instance.on(:structure_notify, :configure_notify, &callback) }
          it "selects both masks" do
            is_expected.to send_message(:XSelectInput).to(Xlib).with(
              :display_ptr, :win_id, Xlib::PropertyChangeMask |
              Xlib::StructureNotifyMask)
          end
        end

        context "when the same standard X event and mask is given again" do
          before { instance.on(mask, type, &callback) }
          it "does not select the mask again" do
            is_expected.not_to send_message(:XSelectInput).to(Xlib).with(
            :display_ptr, :win_id, Xlib::PropertyChangeMask).twice
          end
        end
      end

      context "when a randr event and mask is given (e.g. screen change
        notify)" do
        let(:mask) { :screen_change_notify }
        let(:type) { :screen_change_notify }

        it "selects the mask" do
          is_expected.to send_message(:XRRSelectInput).to(Xlib).with(
          :display_ptr, :win_id, Xlib::RRScreenChangeNotifyMask)
        end
        it { is_expected.to send_message(:XFlush).to(Xlib).with(:display_ptr) }
        it { is_expected.to be callback }

        context "when a second, different standard randr event and mask is
          given" do
          before { instance.on(:output_change_notify, :notify, &callback) }
          it "selects both randr masks" do
            is_expected.to send_message(:XRRSelectInput).to(Xlib).with(
              :display_ptr, :win_id, Xlib::RRScreenChangeNotifyMask |
              Xlib::RROutputChangeNotifyMask)
          end
        end

        context "when the same randr event and mask is given again" do
          before { instance.on(mask, type, &callback) }
          it "does not select the mask again" do
            is_expected.not_to send_message(:XRRSelectInput).to(Xlib).with(
              :display_ptr, :win_id, Xlib::RRScreenChangeNotifyMask).twice
          end
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

    describe ".off: Detaching a callback from an event mask and type" do
      subject { instance.off(mask, type, callback) }

      let(:callback) { Proc.new{} }

      context "when the event has not been registered before" do
        context "when a standard X event and mask is given (e.g. property
          notify)" do
          let(:mask) { :property_change }
          let(:type) { :property_notify }

          it { is_expected.not_to send_message(:XSelectInput).to(Xlib) }
          it { is_expected.not_to send_message(:XFlush).to(Xlib) }
        end

        context "when a randr event and mask is given (e.g. screen change
          notify)" do
          let(:mask) { :screen_change_notify }
          let(:type) { :screen_change_notify }

          it { is_expected.not_to send_message(:XRRSelectInput).to(Xlib) }
          it { is_expected.not_to send_message(:XFlush).to(Xlib) }
        end
      end

      context "when the event has been registered before" do
        before { instance.on(mask, type, &callback) }

        context "when a standard X event and mask is given (e.g. property
          notify)" do
          let(:mask) { :property_change }
          let(:type) { :property_notify }

          it { is_expected.to send_message(:XSelectInput).to(Xlib).with(
            :display_ptr, :win_id, 0) }
          it { is_expected.to send_message(:XFlush).to(Xlib).with(
            :display_ptr).twice }
        end

        context "when a randr event and mask is given (e.g. screen change
          notify)" do
          let(:mask) { :screen_change_notify }
          let(:type) { :screen_change_notify }

          it { is_expected.to send_message(:XRRSelectInput).to(Xlib).with(
            :display_ptr, :win_id, 0) }
          it { is_expected.to send_message(:XFlush).to(Xlib).with(
            :display_ptr).twice }
        end

        context "when a second, different event is registered" do
          context "when a standard X event and mask is given (e.g. property
          notify)" do
            let(:mask) { :property_change }
            let(:type) { :property_notify }

            before { instance.on(:structure_notify, :configure_notify, &callback) }

            it "leaves the mask of the second event intact" do
              is_expected.to send_message(:XSelectInput).to(Xlib).with(
                :display_ptr, :win_id, Xlib::StructureNotifyMask)
            end
          end

          context "when a randr event and mask is given (e.g. screen change
          notify)" do
            let(:mask) { :screen_change_notify }
            let(:type) { :screen_change_notify }

            before { instance.on(:output_change_notify, :notify, &callback) }

            it "leaves the mask of the second event intact" do
              is_expected.to send_message(:XRRSelectInput).to(Xlib).with(
                :display_ptr, :win_id, Xlib::RROutputChangeNotifyMask)
            end
          end
        end
      end

      context "when the mask is used by another event" do
        before { instance.on(mask, :map_notify, &callback) }

        context "when a standard X event and mask is given (e.g. property
          notify)" do
          let(:mask) { :property_change }
          let(:type) { :property_notify }

          it "does not deselect the mask" do
            is_expected.not_to send_message(:XSelectInput).to(Xlib).twice
          end
        end

        context "when a randr event and mask is given (e.g. screen change
          notify)" do
          let(:mask) { :screen_change_notify }
          let(:type) { :screen_change_notify }

          it "does not deselect the mask" do
            is_expected.not_to send_message(:XRRSelectInput).to(Xlib).twice
          end
        end
      end
    end

    describe ".handle: Handling an event" do

    end
  end
end