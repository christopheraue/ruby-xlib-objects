X11 bindings for ruby
=====================

Lightweight object wrappers around a subset of [Xlib](https://github.com/christopheraue/ruby-xlib) to handle displays, screens and windows. Uses Xrandr to deal with multi-monitor setups.

Installation
------------
```
gem install xlib-objects
```

Basic usage
-----------
```ruby
require 'xlib-objects'

display = XlibObj::Display.new(':0')

main_screen = display.screens.first

root_win = main_screen.root_window
root_win.width  # => e.g. 3600
root_win.height # => e.g. 1080

outputs = main_screen.crtcs.map(&:outputs).flatten
outputs.first.name # => e.g. 'DVI-I-1'
outputs.last.name  # => e.g. 'DVI-I-2'
```