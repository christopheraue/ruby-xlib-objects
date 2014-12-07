describe XlibObj::Atom do
  subject(:klass) { described_class.clone }
  subject(:instance) { klass.new(display, atom) }

  let(:display) { instance_double(XlibObj::Display, to_native: :display_ptr) }
  let(:atom_id) { 354 }
  let(:atom) { atom_id }

  describe "The instance" do
    describe "#to_native: Getting the atoms native representation" do
      subject { instance.to_native }

      context "when the atom has been initialized with an integer" do
        let(:atom) { atom_id }
        it { is_expected.to be atom_id }
      end

      context "when the atom has been initialized with the name of an atom" do
        let(:atom) { :ATOM_NAME }

        before { allow(Xlib).to receive(:XInternAtom).with(:display_ptr,
          "ATOM_NAME", false).and_return(atom_id) }

        it { is_expected.to be atom_id }
      end
    end

    describe "#name: Getting its name" do
      subject { instance.name }

      before { allow(Xlib).to receive(:XGetAtomName).with(:display_ptr, atom_id).
        and_return("ATOM_NAME") }

      it { is_expected.to be :ATOM_NAME }
    end

    describe "#exists?: Getting if the atom exists" do
      subject { instance.exists? }

      context "when the atom exists" do
        it { is_expected.to be true }
      end

      context "when the atom does not exist" do
        let(:atom_id) { 0 }
        it { is_expected.to be false }
      end
    end

    describe "#to_s: Getting the atom string representation (i.e. its name)" do
      subject { instance.to_s }
      before { allow(instance).to receive(:name).and_return(:ATOM_NAME) }
      it { is_expected.to eq "ATOM_NAME" }
    end
  end
end