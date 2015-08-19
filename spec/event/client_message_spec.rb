describe XlibObj::Event::ClientMessage do
  subject(:klass) { described_class.clone }
  subject(:instance) { klass.new(:message_type) }

  describe '#send_to: Sending a message to a window' do
    subject { instance.send_to(window) }

    let(:display) { instance_double(XlibObj::Display, to_native: :display_ptr) }
    let(:window) { instance_double(XlibObj::Window, display: display, to_native: :receiver_win_id) }
    let(:event_union) { instance_double(Xlib::XEvent, pointer: :event_ptr) }
    let(:client_event) { {} }
    let(:event_mask) { Xlib::SubstructureNotifyMask | Xlib::SubstructureRedirectMask }

    before { allow(Xlib::XEvent).to receive(:new).and_return(event_union) }
    before { allow(event_union).to receive(:[]).with(:xclient).and_return(client_event) }
    before { allow(client_event).to receive(:[]=) }
    before { allow(XlibObj::Atom).to receive(:new).with(display, :message_type).and_return(
        double(to_native: :message_type_atom_id)) }
    before { allow(Xlib).to receive(:XSendEvent) }
    before { allow(display).to receive(:flush) }

    it { is_expected.to send_message(:[]=).to(client_event).with(:type, 33) }
    it { is_expected.to send_message(:[]=).to(client_event).with(:message_type, :message_type_atom_id) }
    it { is_expected.to send_message(:XSendEvent).to(Xlib).with(:display_ptr, :receiver_win_id,
        false, event_mask, :event_ptr) }
    it { is_expected.to send_message(:flush).to(display) }

    context "when no type is given" do
      before { instance.type = nil }
      it { is_expected.to raise_error }
    end

    context "when a subject is given" do
      before { instance.subject = instance_double(XlibObj::Window, to_native: :subject_win_id) }
      it { is_expected.to send_message(:[]=).to(client_event).with(:window, :subject_win_id) }
    end

    context "when no subject is given" do
      before { instance.subject = nil }
      it { is_expected.to send_message(:[]=).to(client_event).with(:window, :receiver_win_id) }
    end

    context "when no data is given" do
      before { instance.data = nil }
      it { is_expected.not_to send_message(:[]=).to(client_event).with(:format, anything) }
    end

    context "when data is given" do
      let(:sent_data) { { l: [], s: [], b: [] } }
      before { allow(client_event).to receive(:[]).with(:data).and_return(sent_data) }

      context "as 5 longs" do
        let(:data) { [1,2,3,4,5] }
        before { instance.data = data }
        it { is_expected.to send_message(:[]=).to(client_event).with(:format, 32) }
        specify { subject; expect(sent_data[:l]).to eq data }
      end

      context "as 10 shorts" do
        let(:data) { [1,2,3,4,5,6,7,8,9,10] }
        before { instance.data = data }
        it { is_expected.to send_message(:[]=).to(client_event).with(:format, 16) }
        specify { subject; expect(sent_data[:s]).to eq data }
      end

      context "as 20 chars" do
        let(:data) { %w(a b c d e f g h i j k l m n o p q r s t) }
        before { instance.data = data }
        it { is_expected.to send_message(:[]=).to(client_event).with(:format, 8) }
        specify { subject; expect(sent_data[:b]).to eq data }
      end
    end
  end
end