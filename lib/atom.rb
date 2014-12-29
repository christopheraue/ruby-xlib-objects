#
# Copyright (c) 2014 Christopher Aue <mail@christopheraue.net>
#
# This file is part of the ruby xlib-objects gem. It is subject to the license
# terms in the LICENSE file found in the top-level directory of this
# distribution and at http://github.com/christopheraue/ruby-xlib-objects.
#

module XlibObj
  class Atom
    def initialize(display, atom)
      @display = display
      @to_native = if atom.is_a? Integer
                     atom
                   else
                     Xlib.XInternAtom(@display.to_native, atom.to_s, false)
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
      name.to_s
    end
  end
end