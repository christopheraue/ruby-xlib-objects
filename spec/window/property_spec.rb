describe CappX11::Window::Property do
  describe '.get' do
    it 'requests property data from the X server and maps it to an instance' do
      window = build(:window)
      prop = described_class.get(window, :_NET_CLIENT_LIST)

      expect(prop).to be_a(Array)
    end
  end

  describe '.all' do
    it 'requests all properties from the X server and maps them to an instance' do
      window = build(:window)
      props = described_class.all(window)

      expect(props).to be_a(Hash)
      props.each do |name, value|
        expect(name).to be_a(Symbol)
        expect(value).not_to be(nil)
      end
    end
  end
end