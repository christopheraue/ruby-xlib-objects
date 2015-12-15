require 'bundler/setup'
Bundler.require

display = XlibObj::Display.new(':0')

puts display.extensions.map(&:name)