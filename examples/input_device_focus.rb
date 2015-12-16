require 'bundler/setup'
Bundler.require

display = XlibObj::Display.new(':0')

root_window = display.screens.first.root_window
top_level_windows = root_window.property(:_NET_CLIENT_LIST_STACKING)
keyboards = display.input_devices.select(&:keyboard?)

top_level_windows.each do |window|
  %i(xi_focus_in xi_focus_out).each do |name, _|
    window.on(name, name) do |event|
      puts "#{event.event}: #{XlibObj::Extension::XI::Event::TYPES.key(event.evtype)}, device #{event.deviceid}"
    end
  end

  window.on(:xi_key_press, :xi_key_press) do |event|
    next if event.deviceid < 4
    keyboards.sample.focused_window = top_level_windows.sample
  end
end

loop do
  display.handle_events
end

