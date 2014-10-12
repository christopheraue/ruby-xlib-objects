describe Xlib::Display do
  let(:subject) { described_class.open(':0') }
  let(:display_struct) { build(:display_struct) }

  describe 'Class Methods' do
    describe '.open' do
      context 'valid display name' do
        it 'instanciates a display' do
          display = described_class.open(':0')

          expect(display).to be_a(described_class)
        end
      end

      context 'invalid display name' do
        it 'returns an error' do
          expect{ described_class.open('invalid') }.to raise_error
        end
      end
    end

    describe '.names' do
      it 'returns the names of all connected displays' do
        # given
        allow(Dir).to receive(:[]).with('/tmp/.X11-unix/*').and_return(%w(X0 X1))

        # when
        names = described_class.names

        # then
        expect(names).to eq(%w(:0 :1))
      end
    end

    describe '.all' do
      it 'opens all displays' do
        # given
        allow(described_class).to receive(:names).and_return(%w(:0 :1))
        allow(described_class).to receive(:open).with(':0').and_return('display :0')
        allow(described_class).to receive(:open).with(':1').and_return('display :1')

        # when
        displays = described_class.all

        # then
        expect(displays).to contain_exactly('display :0', 'display :1')
      end
    end
  end

  describe 'Instance Methods' do
    describe '#to_native' do
      it 'returns the display\'s native pointer' do
        expect(subject.to_native).to be_a(FFI::Pointer)
      end
    end

    describe '#name' do
      it 'returns the name of the display' do
        expect(subject.name).to eq(':0')
      end
    end

    describe '#screens' do
      it 'returns an array with all screens' do
        #when
        screens = subject.screens

        #then
        expect(screens).to be_a(Array)
        expect(screens.size).to eq(display_struct[:nscreens])
        screens.each do |screen|
          expect(screen).to be_a(Xlib::Screen)
        end
      end
    end

    describe '#handle_events' do
      it 'works'
    end

    describe '#file_descriptor' do
      it 'returns the display\'s file descriptor' do
        expect(subject.file_descriptor).to be_a(Integer)
      end
    end
  end
end