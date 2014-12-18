Gem::Specification.new do |s|
  s.name         = 'xlib-objects'
  s.version      = '0.0.1'
  s.author       = 'Christopher Aue'
  s.email        = 'mail@christopheraue.net'
  s.platform     = Gem::Platform::RUBY
  s.summary      = 'Light object wrapper around Xlib'
  s.files        = Dir.glob('lib/**/*.rb')
  s.require_path = 'lib'

  s.add_dependency 'xlib'
end
