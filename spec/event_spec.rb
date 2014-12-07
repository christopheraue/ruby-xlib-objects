describe XlibObj::Event do
  subject(:klass) { described_class.clone }
  subject(:instance) { klass.new(event) }

  describe "The class" do
    describe ".xrr_type_offset: Getting the event type offset of Xrandr
      events" do
      subject { klass.xrr_type_offset(:display) }
      let(:event_offset_ptr) { instance_double(FFI::MemoryPointer, read_int:
        :event_offset) }
      let(:error_offset_ptr) { instance_double(FFI::MemoryPointer) }

      before { allow(Xlib).to receive(:XRRQueryExtension) }
      before { allow(FFI::MemoryPointer).to receive(:new).and_return(
        event_offset_ptr, error_offset_ptr) }

      it { is_expected.to be :event_offset }
    end
  end

  describe "The instance" do
    let(:xrr_type_offset) { Xlib::LASTEvent+1 }
    let(:event) { { type: event_type, xany: any_event } }
    let(:any_event) { { type: event_type, display: :display } }

    before { allow(klass).to receive(:xrr_type_offset).and_return(
      xrr_type_offset) }
    before { allow(event).to receive(:pointer) }

    describe "#~attribute_key~: Getting one of the X event's attributes" do
      subject { instance }

      context 'when the event is a standard X event (e.g property notify)' do
        let(:event_type) { Xlib::PropertyNotify }
        let(:event) { { type: event_type, xproperty: property_event, xany:
          any_event } }
        let(:property_event) { { type: event_type, display: :display, window:
          :window, atom: :atom } }

        before { allow(property_event).to receive(:members).and_return(
          [:display, :window, :atom]) }

        its(:type) { is_expected.to be Xlib::PropertyNotify }
        its(:display) { is_expected.to be :display }
        its(:window) { is_expected.to be :window }
        its(:atom) { is_expected.to be :atom }
      end

      context 'when the event is a Xrandr event' do
        context 'when the event is a screen change notify event' do
          let(:event_type) { xrr_type_offset + Xlib::RRScreenChangeNotify }
          let(:screen_change_event) { { type: event_type, display: :display,
            window: :window } }

          before { allow(Xlib::XRRScreenChangeNotifyEvent).to receive(:new).
            and_return(screen_change_event) }
          before { allow(screen_change_event).to receive(:members).and_return(
            screen_change_event.keys) }

          its(:type) { is_expected.to be event_type }
          its(:display) { is_expected.to be :display }
          its(:window) { is_expected.to be :window }
        end

        context 'when the event is a notify event with sub type (e.g. output
          change notify)' do
          let(:event_type) { xrr_type_offset + Xlib::RRNotify }
          let(:event_sub_type) { Xlib::RRNotify_OutputChange }
          let(:notify_event) { { type: event_type, display: :display,
            window: :window, subtype: event_sub_type } }
          let(:output_change_event) { { type: event_type, display: :display,
            window: :window, subtype: event_sub_type } }

          before { allow(Xlib::XRRNotifyEvent).to receive(:new).
            and_return(notify_event) }
          before { allow(Xlib::XRROutputChangeNotifyEvent).to receive(:new).
            and_return(output_change_event) }
          before { allow(output_change_event).to receive(:members).and_return(
            output_change_event.keys) }

          its(:type) { is_expected.to be event_type }
          its(:display) { is_expected.to be :display }
          its(:window) { is_expected.to be :window }
          its(:subtype) { is_expected.to be event_sub_type }
        end
      end
    end

    describe "#name: Getting the event's name" do
      subject { instance.name }

      context 'when the event is a standard X event (e.g property notify)' do
        let(:event_type) { Xlib::PropertyNotify }
        it { is_expected.to be :property_notify }
      end

      context 'when the event is a Xrandr event' do
        context 'when the event is a screen change notify event' do
          let(:event_type) { xrr_type_offset + Xlib::RRScreenChangeNotify }
          it { is_expected.to be :screen_change_notify }
        end

        context 'when the event is a notify event with sub type (e.g. output
          change notify)' do
          let(:event_type) { xrr_type_offset + Xlib::RRNotify }
          let(:event_sub_type) { Xlib::RRNotify_OutputChange }
          let(:notify_event) { { type: event_type, display: :display,
            window: :window, subtype: event_sub_type } }
          let(:output_change_event) { { type: event_type, display: :display,
            window: :window, subtype: event_sub_type } }

          before { allow(Xlib::XRRNotifyEvent).to receive(:new).
            and_return(notify_event) }
          before { allow(Xlib::XRROutputChangeNotifyEvent).to receive(:new).
            and_return(output_change_event) }
          before { allow(output_change_event).to receive(:members).and_return(
            output_change_event.keys) }
          it { is_expected.to be :output_change_notify }
        end
      end
    end
  end
end