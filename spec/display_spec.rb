describe Xlib::Display do
  let(:subject) { described_class.open(':0') }
  let(:display_struct) { build(:display_struct) }

  describe 'Class Methods' do
    describe '.open' do
      context 'valid display name' do
        it 'opens a display' do
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
  end
end