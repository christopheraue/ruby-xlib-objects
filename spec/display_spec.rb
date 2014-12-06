describe XlibObj::Display do
  subject(:klass) { described_class.clone }
  subject(:instance) { klass.new(:display_name) }

  let(:display_ptr) { double(null?: false) }
  let(:display_struct) { instance_double(Xlib::Display, pointer: display_ptr) }

  before { allow(Xlib).to receive(:XOpenDisplay).and_return(display_ptr) }
  before { allow(Xlib::Display).to receive(:new).with(display_ptr).
    and_return(display_struct) }
  before { allow(display_struct).to receive(:[]).with(:display_name).
    and_return(:display_name) }


  describe 'The class' do
    describe '.names: Getting the names of all available displays' do
      subject { klass.names }
      before { allow(Dir).to receive(:[]).with('/tmp/.X11-unix/*').
        and_return(%w(X0 X1)) }
      it { is_expected.to eq %w(:0 :1) }
    end
  end

  describe 'The instance' do
    describe '#to_native: Getting its native representation' do
      subject { instance.to_native }
      it { is_expected.to be(display_ptr) }
    end

    describe '#name: Getting its name' do
      subject { instance.name }
      it { is_expected.to eq :display_name}
    end

    describe '#socket: Getting its socket handling communication' do
      subject { instance.socket }
      before { allow(Xlib).to receive(:XConnectionNumber).with(display_ptr).
        and_return(:file_descriptor) }
      before { allow(UNIXSocket).to receive(:for_fd).with(:file_descriptor).
        and_return(:socket) }
      it { is_expected.to be :socket }
    end

    describe '#screens: Getting models of all its available screens' do
      subject { instance.screens }

      let(:screen_struct_size) { Xlib::Screen.size }

      before { allow(display_struct).to receive(:[]).with(:nscreens).
        and_return(2) }
      before { allow(display_struct).to receive(:[]).with(:screens).
        and_return(1000000) } #screens pointer address
      before { allow(XlibObj::Screen).to receive(:new).with(instance, 1000000).
        and_return(:screen1) }
      before { allow(XlibObj::Screen).to receive(:new).with(instance,
        1000000+screen_struct_size).and_return(:screen2) }

      it { is_expected.to eq [:screen1, :screen2] }
    end

    describe '#handle_events: Handles all events waiting in the queue' do
      subject { instance.handle_events }

      context 'when there are no waiting events' do
        before { allow(Xlib).to receive(:XPending).with(display_ptr).
          and_return(0) }
        it { is_expected.not_to send_message(:XNextEvent).to(Xlib) }
      end

      context 'when there are waiting events' do
        before { allow(Xlib).to receive(:XPending).with(display_ptr).
          and_return(1, 0) } # 0 on second call so we exit the loop

        let(:event_window) { instance_double(XlibObj::Window) }
        let(:parent_window) { instance_double(XlibObj::Window) }
        let(:window) { instance_double(XlibObj::Window) }

        before { allow(Xlib::XEvent).to receive(:new).and_return(:x_event) }
        before { allow(Xlib).to receive(:XNextEvent).with(display_ptr,
          :x_event) }
        before { allow(XlibObj::Event).to receive(:new).with(:x_event).
          and_return(event) }
        before { allow(XlibObj::Window).to receive(:new).with(instance,
          :event_window_id).and_return(event_window) }
        before { allow(XlibObj::Window).to receive(:new).with(instance,
          :parent_window_id).and_return(parent_window) }
        before { allow(XlibObj::Window).to receive(:new).with(instance,
          :window_id).and_return(window) }

        context 'when the event member of the event carries a window' do
          let(:event) { double(XlibObj::Event, event: :event_window_id,
            parent: :parent_window_id, window: :window_id) }

          it { is_expected.to send_message(:handle).to(event_window).
            with(event) }
        end

        context 'when the parent member of the event carries a window' do
          let(:event) { double(XlibObj::Event, event: nil,
            parent: :parent_window_id, window: :window_id) }

          it { is_expected.to send_message(:handle).to(parent_window).
            with(event) }
        end

        context 'when the window member of the event carries a window' do
          let(:event) { double(XlibObj::Event, event: nil,
            parent: nil, window: :window_id) }

          it { is_expected.to send_message(:handle).to(window).
            with(event) }
        end
      end
    end
  end
end