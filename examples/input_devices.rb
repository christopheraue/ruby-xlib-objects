require 'bundler/setup'
Bundler.require

display = XlibObj::Display.new(':0')

display.input_devices.each do |device|
  puts <<-DEVICE
#{device.id} #{device.name}
  type: #{device.keyboard? ? "keyboard (focus: #{device.focus.id})" : 'pointer'}
  hierarchy: #{device.master? ? 'master' : "slave (under: #{device.master.id})"} #{device.floating? ? '(floating)' : ''}
  enabled? #{device.enabled?}
  DEVICE
end