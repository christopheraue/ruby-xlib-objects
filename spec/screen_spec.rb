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

      # then
      expect(clients).to be_a(Array)
      clients.each do |client|
        expect(client).to be_a(CappX11::Window)
      end
    end
  end

  describe '#sub_screens' do
    it 'returns an array with all xrandr sub screens' do
      # when
      sub_screens = subject.sub_screens

      # then
      expect(sub_screens).to be_a(Array)
      sub_screens.each do |sub_screen|
        expect(sub_screen).to be_a(CappX11::SubScreen)
      end
    end
  end
end