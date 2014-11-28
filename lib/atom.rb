class CappX11::Atom
  def intialize(display, atom)
    @display = display
    @atom = if atom.is_a? Integer
              atom
            else
              X11::Xlib.XInternAtom(@display.to_native, atom.to_s, true)
            end
  end

  attr_reader :atom

  def name
    X11::Xlib.XGetAtomName(@display.to_native, @atom).to_sym
  end
end