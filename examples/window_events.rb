require 'bundler/setup'
Bundler.require

display = XlibObj::Display.new(':0')

root_window = display.screens.first.root_window
top_level_windows = root_window.property(:_NET_CLIENT_LIST_STACKING)

top_level_windows.each do |window|
  window.on(:structure_notify, :configure_notify) do |event|
    window = XlibObj::Window.new(display, event.window)
    puts "window #{event.window}: (#{window.absolute_position[:x]},#{window.absolute_position[:y]})+(#{window.width}x#{window.height})"
  end

  window.on(:property_change, :property_notify) do |event|
    window = XlibObj::Window.new(display, event.window)
    property = XlibObj::Atom.new(display, event.atom).name
    puts "window #{event.window} #{property}: #{window.property(property)}"
  end

  window.on(:focus_change, :focus_in) do |event|
    puts "window #{event.window} gained focus"
  end

  window.on(:focus_change, :focus_out) do |event|
    puts "window #{event.window} lost focus"
  end
end

loop do
  display.handle_events
end

