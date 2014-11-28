module CappX11
  class Atom
    def intialize(display, atom)
      @display = display
      @to_native = if atom.is_a? Integer
                     atom
                   else
                     X11::Xlib.XInternAtom(@display.to_native, atom.to_s, true)
                   end
    end

    attr_reader :to_native

    def name
      X11::Xlib.XGetAtomName(@display.to_native, @atom).to_sym
    end

    def exists?
      to_native != 0
    end

    def to_s
      name
    end
  end
end