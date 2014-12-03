describe XlibObj::Event::ClientMessage do
  subject(:klass) { described_class.clone }
  subject(:instance) { klass.new }

  describe 'sending a message to a window' do
    subject { instance.send_to(window) }

    let(:display) { instance_double(XlibObj::Display, to_native: :display_ptr) }
    let(:window) { instance_double(XlibObj::Window, display: display,
      to_native: :win_id) }

    before { allow(Xlib).to receive(:XSendEvent) }
    before { allow(Xlib).to receive(:XFlush) }
    before { allow(instance).to receive(:to_native).and_return(:event_ptr)}

    it { is_expected.to send_message(:XSendEvent).to(Xlib).with(:display_ptr,
      :win_id, false,
      Xlib::SubstructureNotifyMask | Xlib::SubstructureRedirectMask,
      :event_ptr) }
    it { is_expected.to send_message(:XFlush).to(Xlib).with(:display_ptr) }
  end
end