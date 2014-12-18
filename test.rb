require_relative 'lib/Xlib-objects'

display = XlibObj::Display.new(':0')
crtcs = display.screens.first.crtcs
outputs = crtcs.map(&:outputs).flatten
puts outputs.first.name