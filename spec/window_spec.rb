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

  describe '#map' do
    it 'maps the window' do
      # then
      expect(Xlib::Capi).to receive(:XMapWindow).
        with(subject.display.to_native, subject.to_native)

      # when
      subject.map
    end
  end

  describe '#unmap' do
    it 'unmaps the window' do
      # then
      expect(Xlib::Capi).to receive(:XUnmapWindow).
        with(subject.display.to_native, subject.to_native)

      # when
      subject.unmap
    end
  end

  describe '#map_state' do
    it 'returns the map state' do
      map_state = subject.map_state
      expect(map_state).to be_a(String)
    end
  end

  describe '#mapped?' do
    context 'map_state is not "IsUnmapped"' do
      it 'returns true' do
        #given
        allow(subject).to receive(:attributes).
          and_return({ map_state: 2})

        #when/then
        expect(subject.mapped?).to be(true)
      end
    end

    context 'map_state is "IsUnmapped"' do
      it 'returns false' do
        #given
        allow(subject).to receive(:attributes).
          and_return({ map_state: 0 })

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
          and_return({ map_state: 2 })

        #when/then
        expect(subject.visible?).to be(true)
      end
    end

    context 'map_state is not "IsViewable"' do
      it 'returns false' do
        #given
        allow(subject).to receive(:attributes).
          and_return({ map_state: 1 })

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
    it 'returns a hash with all set properties' do
      # given
      prop_list = { prop1: 'prop1 value', prop2: 'prop2 value', prop3: 'prop3 value'}
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
      prop_name  = 'prop name'
      prop_value = 'prop value'
      allow(Xlib::Window::Property).to receive(:get).with(subject, prop_name).
        and_return(prop_value)

      # when
      prop = subject.property(prop_name)

      # then
      expect(prop).to eq(prop_value)
    end
  end

  describe '#listen_to' do
    context 'The given event mask is invalid' do
      it 'fails' do
        expect { subject.listen_to(:invalid_mask) }.to raise_error
      end
    end

    context 'The given event mask is valid' do
      it 'lets the window listen to an event mask' do
        # then
        expect(Xlib::Capi).to receive(:XSelectInput).with(
          subject.display.to_native,
          subject.to_native,
          Xlib::Capi::EVENT_MASK[:property_change]
        )

        # when
        returned = subject.listen_to :property_change

        # then
        expect(returned).to be(subject)
      end

      it 'adds to the event mask on a subsequent call' do
        # given
        subject.listen_to :property_change do |event| event end

        # then
        expect(Xlib::Capi).to receive(:XSelectInput).with(
          subject.display.to_native,
          subject.to_native,
          Xlib::Capi::EVENT_MASK[:property_change] | Xlib::Capi::EVENT_MASK[:structure_notify]
        )

        # when
        subject.listen_to :structure_notify do |event| event end
      end
    end
  end

  describe '#turn_deaf_on' do
    context 'The given event mask is invalid' do
      it 'fails' do
        expect { subject.turn_deaf_on(:invalid_mask) }.to raise_error
      end
    end

    context 'The given event mask is valid' do
      it 'discontinues listening to the given event_mask' do
        # given
        subject.listen_to :property_change do |event| event end
        subject.listen_to :structure_notify do |event| event end

        # then
        expect(Xlib::Capi).to receive(:XSelectInput).with(
          subject.display.to_native,
          subject.to_native,
          Xlib::Capi::EVENT_MASK[:structure_notify]
        )

        # when
        returned = subject.turn_deaf_on :property_change

        # then
        expect(returned).to be(subject)
      end
    end
  end

  describe '#on' do
    context 'The given event is invalid' do
      it 'fails' do
        expect { subject.on(:invalid_event) }.to raise_error
      end
    end

    it 'registers a handler for the event and returns self' do
      # when
      ret = subject.on(:property_notify) do; end

      # then
      expect(ret).to be(subject)
    end
  end

  describe '#handle' do
    let(:event) { Xlib::Event.new(build(:x_event, window: subject)) }

    context 'no event handler registered' do
      it 'does nothing' do
        expect { subject.handle(event) }.not_to raise_error
      end
    end

    it 'executes the event handler' do
      # given
      block = lambda{|event|}
      subject.on(:property_notify, &block)

      # then
      expect(block).to receive(:call)

      # when
      subject.handle(event)
    end
  end
end