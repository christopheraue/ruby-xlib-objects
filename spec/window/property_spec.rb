describe XlibObj::Window::Property do
  subject(:klass) { described_class.clone }
  subject(:instance) { klass.new(window, :property_name) }

  let(:display) { instance_double(XlibObj::Display, to_native: :display_ptr) }
  let(:window) { instance_double(XlibObj::Window, display: display, to_native:
    :win_id) }
  let(:property_atom) { instance_double(XlibObj::Atom, to_native: :atom_id) }

  before { allow(XlibObj::Atom).to receive(:new).with(display, :property_name).
    and_return(property_atom) }

  describe "The instance" do
    describe "#get: Getting its value" do
      subject { instance.get }

      # stubs for a successful property request
      before { allow(property_atom).to receive(:exists?).and_return(true) }
      before { allow(Xlib).to receive(:XGetWindowProperty).and_return(0) }
      before { allow(FFI::MemoryPointer).to receive(:new).with(:pointer).
        and_return(pointer) }

      let(:pointer) { instance_double(FFI::MemoryPointer, read_pointer:
        double(null?: false)) }

      # stubs for meaningful property data
      let(:items) { [:item] }

      let(:item_type) { :BYTES }
      let(:item_type_ptr) { instance_double(FFI::MemoryPointer, read_int:
        :item_type_id) }
      let(:item_type_atom) { instance_double(XlibObj::Atom, name: item_type) }
      before { allow(FFI::MemoryPointer).to receive(:new).with(:Atom).
        and_return(item_type_ptr) }
      before { allow(XlibObj::Atom).to receive(:new).with(display,
        :item_type_id).and_return(item_type_atom) }

      let(:item_width_ptr) { instance_double(FFI::MemoryPointer, read_int:
        :item_width) }
      before { allow(FFI::MemoryPointer).to receive(:new).with(:int).
        and_return(item_width_ptr) }

      let(:item_count_ptr) { instance_double(FFI::MemoryPointer, read_int:
        items.size) }
      before { allow(FFI::MemoryPointer).to receive(:new).with(:ulong).
        and_return(item_count_ptr) }

      let(:bytes) { "\0" }
      before { allow(instance).to receive(:read_bytes).and_return(bytes) }

      context "when the atom does not exist" do
        before { allow(property_atom).to receive(:exists?).and_return(false) }
        it { is_expected.to be nil }
      end

      context "when retrieving the property's value from the X server returns
        an error status" do
        before { allow(Xlib).to receive(:XGetWindowProperty).and_return(1) }
        it { is_expected.to be nil }
      end

      context "when the property is not set for the window" do
        let(:pointer) { instance_double(FFI::MemoryPointer, read_pointer:
          double(null?: true)) }
        it { is_expected.to be nil }
      end

      context "when the property value contains no data" do
        let(:item_count_ptr) { instance_double(FFI::MemoryPointer, read_int: 0) }
        it { is_expected.to be nil }
      end

      context 'when the extracted items result in an empty array' do
        before { allow(instance).to receive(:bytes_to_items).and_return([]) }
        it { is_expected.to be nil }
      end

      context "when the property contains byte data" do
        let(:items) { %w(b b b) }
        let(:item_type) { :BYTES }
        let(:bytes) { items.pack('a'*items.size) }

        it { is_expected.to eq items }
      end

      context "when there is only one extracted item (valid for property data
        of all types)" do
        let(:items) { %w(b) }
        let(:item_type) { :BYTES }
        let(:bytes) { items.pack('a') }

        it { is_expected.to eq 'b' }
      end

      context "when the property contains integers" do
        let(:items) { [1,2,3] }
        let(:item_type) { :INTEGER }
        before { allow(instance).to receive(:read_bytes).and_return(items.
          pack('i!'*items.size)) }

        it { is_expected.to eq items }
      end

      context "when the property contains cardinals" do
        let(:items) { [1,2,3] }
        let(:item_type) { :CARDINAL }
        let(:bytes) { items.pack('L!'*items.size) }

        it { is_expected.to eq items }
      end

      context "when the property contains atoms" do
        let(:items) { [1,2,3] }
        let(:item_type) { :ATOM }
        let(:bytes) { items.pack('L!'*items.size) }
        before { allow(XlibObj::Atom).to receive(:new).
          with(display, kind_of(Integer)) { |_, atom_id| :"atom#{atom_id}" } }

        it { is_expected.to eq [:atom1, :atom2, :atom3] }
      end

      context "when the property contains windows" do
        let(:items) { [1,2,3] }
        let(:item_type) { :WINDOW }
        let(:bytes) { items.pack('L!'*items.size) }
        before { allow(XlibObj::Window).to receive(:new).
          with(display, kind_of(Integer)) { |_, win_id| :"win#{win_id}" } }

        it { is_expected.to eq [:win1, :win2, :win3] }
      end

      context "when the property contains ascii strings" do
        let(:items) { %w(string1 string2 string3) }
        let(:item_type) { :STRING }
        let(:bytes) { items.pack('Z*'*items.size) }

        it { is_expected.to eq items }
        it { is_expected.to satisfy do |strings|
          strings.first.encoding == Encoding::ASCII_8BIT
        end }
      end

      context "when the property contains ascii strings" do
        let(:items) { %w(string1 string2 string3) }
        let(:item_type) { :UTF8_STRING }
        let(:bytes) { items.pack('Z*'*items.size) }

        it { is_expected.to eq items }
        it { is_expected.to satisfy do |strings|
          strings.first.encoding == Encoding::UTF_8
        end }
      end
    end

    describe "#set: Setting its value" do
      subject { instance.set(value, given_type) }

      let(:value) { "\0" }
      let(:given_type) { nil }
      let(:item_type) { :UTF8_STRING }

      before { allow(Xlib).to receive(:XChangeProperty) }
      before { allow(Xlib).to receive(:XFlush) }
      before { allow(XlibObj::Atom).to receive(:new).with(display, item_type) do |_, item_type|
        instance_double(XlibObj::Atom, to_native: :"#{item_type}_atom_id")        end }

      it { is_expected.to send_message(:XFlush).to(Xlib).with(:display_ptr) }
      it { is_expected.to be instance }

      context "when an array of integers is given" do
        context "when all integers are positive and no type is explicitly
          given" do
          let(:value) { [29, 145] }
          let(:item_type) { :CARDINAL }
          it "treats the values as CARDINAL" do
            is_expected.to send_message(:XChangeProperty).to(Xlib).with(
              :display_ptr, :win_id, :atom_id, :CARDINAL_atom_id, 32, 0,
              value.pack('L!'*value.size), 2)
          end
        end

        context "when at least one of the integers is negative and no type is
          explicitly given" do
          let(:value) { [29, -145] }
          let(:item_type) { :INTEGER }
          it "treats the values as INTEGER" do
            is_expected.to send_message(:XChangeProperty).to(Xlib).with(
              :display_ptr, :win_id, :atom_id, :INTEGER_atom_id, 16, 0,
              value.pack('i!'*value.size), 2)
          end
        end

        context "when they should be explicitly handled as of type INTEGER" do
          let(:value) { [29, 145] }
          let(:given_type) { :INTEGER }
          let(:item_type) { :INTEGER }
          it { is_expected.to send_message(:XChangeProperty).to(Xlib).with(
            :display_ptr, :win_id, :atom_id, :INTEGER_atom_id, 16, 0,
            value.pack('i!'*value.size), 2) }
        end
      end

      context "when an array of atoms is given" do
        let(:value) { [XlibObj::Atom.new(display, 1), XlibObj::Atom.new(
          display, 2)] }
        let(:item_type) { :ATOM }

        before { allow(XlibObj::Atom).to receive(:new).with(display, 1).
          and_call_original }
        before { allow(XlibObj::Atom).to receive(:new).with(display, 2).
          and_call_original }

        it { is_expected.to send_message(:XChangeProperty).to(Xlib).with(
          :display_ptr, :win_id, :atom_id, :ATOM_atom_id, 32, 0,
          [1,2].pack('L!'*value.size), 2) }
      end

      context "when an array of windows is given" do
        let(:value) { [XlibObj::Window.new(display, 1), XlibObj::Window.new(
          display, 2)] }
        let(:item_type) { :WINDOW }

        it { is_expected.to send_message(:XChangeProperty).to(Xlib).with(
          :display_ptr, :win_id, :atom_id, :WINDOW_atom_id, 32, 0,
          [1,2].pack('L!'*value.size), 2) }
      end

      context "when an array of ascii strings is given" do
        let(:value) do %w(ascii1 ascii2).map{ |s|
          s.force_encoding('ASCII-8BIT') } end
        let(:item_type) { :STRING }

        it { is_expected.to send_message(:XChangeProperty).to(Xlib).with(
            :display_ptr, :win_id, :atom_id, :STRING_atom_id, 8, 0,
            value.pack('Z*'*value.size), value.join.length+value.size) }
      end

      context "when an array of utf8 strings is given" do
        let(:value) do %w(ascii1 ascii2).map{ |s|
          s.force_encoding('UTF-8') } end
        let(:item_type) { :UTF8_STRING }

        it { is_expected.to send_message(:XChangeProperty).to(Xlib).with(
          :display_ptr, :win_id, :atom_id, :UTF8_STRING_atom_id, 8, 0,
          value.pack('Z*'*value.size), value.join.length+value.size) }
      end

      context "when a single item is given (integer as example, but also valid
        for all other kinds of types)" do
        let(:value) { 29 }
        let(:item_type) { :CARDINAL }
        it "treats the values as CARDINAL" do
          is_expected.to send_message(:XChangeProperty).to(Xlib).with(
            :display_ptr, :win_id, :atom_id, :CARDINAL_atom_id, 32, 0,
            [value].pack('L!'), 1)
        end
      end
    end
  end
end