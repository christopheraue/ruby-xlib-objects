describe CappX11::Screen do
  let(:subject) { build(:screen) }

  describe '#to_native' do
    it 'returns the native pointer of the screen' do
      expect(subject.to_native).to be_a(FFI::Pointer)
    end
  end

  describe '#root_window' do
    it 'returns the root window' do
      expect(subject.root_window).to be_a(CappX11::Window)
      expect(subject.root_window.to_native).to be(
        X11::Xlib.XRootWindow(subject.display.to_native, 0)
      )
    end
  end

  describe '#client_windows' do
    it 'returns all top-level client windows' do
      # when
      clients = subject.client_windows

      expect(clients).to be_a(Array)
      clients.each do |client|
        expect(client).to be_a(CappX11::Window)
      end
    end
  end
end