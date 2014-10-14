describe CappX11::SubScreen do
  let(:subject) { build(:sub_screen) }

  describe '#left' do
    it 'returns x property of crtc info'
  end

  describe '#top' do
    it 'returns y property of crtc info'
  end

  describe '#width' do
    it 'returns width property of crtc info'
  end

  describe '#height' do
    it 'returns height property of crtc info'
  end
end