module XlibObj
  class Atom
    def initialize(display, atom)
      @display = display
      @to_native = if atom.is_a? Integer
                     atom
                   else
                     Xlib.XInternAtom(@display.to_native, atom.to_s, true)
                   end
    end

    attr_reader :to_native

    def name
      Xlib.XGetAtomName(@display.to_native, @to_native).to_sym
    end

    def exists?
      @to_native != 0
    end

    def to_s
      name
    end
  end
end