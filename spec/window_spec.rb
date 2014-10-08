describe Xlib::Window do
  let(:subject) { build(:window) }

  describe '#to_native' do
    it 'returns the native pointer of the window' do
      expect(subject.to_native).to be_a(Integer)
    end
  end

  describe '#left' do
    it 'returns the x coordinate' do
      left = subject.left
      expect(left).to be_a(Integer)
    end
  end

  describe '#top' do
    it 'returns the y coordinate' do
      top = subject.top
      expect(top).to be_a(Integer)
    end
  end

  describe '#width' do
    it 'returns the width' do
      width = subject.width
      expect(width).to be_a(Integer)
    end
  end

  describe '#height' do
    it 'returns the height' do
      height = subject.height
      expect(height).to be_a(Integer)
    end
  end

  describe '#mapped?' do
    context 'map_state is not "IsUnmapped"' do
      it 'returns true' do
        #given
        allow(subject).to receive(:attributes).
          and_return({ map_state: 'IsViewable' })

        #when/then
        expect(subject.mapped?).to be(true)
      end
    end

    context 'map_state is "IsUnmapped"' do
      it 'returns false' do
        #given
        allow(subject).to receive(:attributes).
          and_return({ map_state: 'IsUnmapped' })

        #when/then
        expect(subject.mapped?).to be(false)
      end
    end
  end

  describe '#visible?' do
    context 'map_state is "IsViewable"' do
      it 'returns true' do
        #given
        allow(subject).to receive(:attributes).
          and_return({ map_state: 'IsViewable' })

        #when/then
        expect(subject.visible?).to be(true)
      end
    end

    context 'map_state is not "IsViewable"' do
      it 'returns false' do
        #given
        allow(subject).to receive(:attributes).
          and_return({ map_state: 'IsUnviewable' })

        #when/then
        expect(subject.visible?).to be(false)
      end
    end
  end

  describe '#screen' do
    it 'returns the screen the window is living in' do
      expect(subject.screen).to be_a(Xlib::Screen)
    end
  end

  describe '#display' do
    it 'returns the display the window is living in' do
      expect(subject.display).to be_a(Xlib::Display)
    end
  end

  describe '#properties' do
    it 'returns an array with all set properties' do
      # given
      prop_list = build_list(:property, 3)
      allow(Xlib::Window::Property).to receive(:all).with(subject).
        and_return(prop_list)

      # when
      props = subject.properties

      # then
      expect(props).to eq(prop_list)
    end
  end

  describe '#property' do
    it 'returns the value for a specific property' do
      # given
      prop = build(:property)
      allow(Xlib::Window::Property).to receive(:get).with(subject, prop.name).
        and_return(prop)

      # when
      prop_value = subject.property(prop.name)

      # then
      expect(prop_value).to eq(prop.value)
    end
  end
end