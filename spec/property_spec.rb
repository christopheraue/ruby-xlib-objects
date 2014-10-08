describe Xlib::Window::Property do
  let(:subject) { build(:property) }

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

  describe '#to_native' do
    it 'returns its pointer' do
      expect(subject.to_native).to be_a(FFI::Pointer)
    end
  end

  describe '#window' do
    it 'returns its window' do
      expect(subject.window).to be_a(Xlib::Window)
    end
  end

  describe '#name' do
    it 'returns its name' do
      expect(subject.name).to eq('prop_name')
    end
  end

  describe '#value' do
    it 'returns its value' do
      expect(subject.value).to eq('prop_value')
    end
  end
end