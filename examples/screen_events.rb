require 'bundler/setup'
Bundler.require

display = XlibObj::Display.new(':0')

screen = display.screens.first

screen.root_window.on(:screen_change_notify, :screen_change_notify) do |event|
  screen.crtcs.each do |crtc|
    connected = crtc.outputs.map(&:connection).any?(&:zero?)
    outputs = crtc.outputs.map(&:name).join(',')
    top = crtc.y
    left = crtc.x
    width = crtc.width
    height = crtc.height

    puts "screen #{crtc.id} (#{connected ? "#{outputs}" : 'disconnected'}): (#{left},#{top})+(#{width}x#{height})"
  end
end

loop do
  display.handle_events
end

