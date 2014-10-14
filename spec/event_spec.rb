describe CappX11::Event do
  describe '#initialize' do
    it 'maps the event attributes to methods' do
      # given
      window = build(:window)
      x_event = build(:x_event, window: window)

      # when
      event = described_class.new(x_event)

      # then
      expect(event).to be_a(CappX11::Event)
      expect(event.type).to be(28)
      expect(event.serial).to be(0)
      expect(event.send_event).to be(false)
      expect(event.display).to be(window.display.to_native.read_pointer)
      expect(event.window).to be(window.to_native)
      expect(event.atom).to be(39)
      expect(event.time).to be(1412860400)
      expect(event.state).to be(X11::Xlib::PROPERTY_NEW_VALUE)
    end
  end
end