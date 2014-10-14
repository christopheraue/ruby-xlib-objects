Gem::Specification.new do |s|
  s.name         = 'capp-x11'
  s.version      = '0.0.1'
  s.author       = 'Christopher Aue'
  s.email        = 'mail@christopheraue.net'
  s.platform     = Gem::Platform::RUBY
  s.summary      = 'Wrapper objects around the X11 interface'
  s.files        = Dir.glob('lib/**/*.rb')
  s.require_path = 'lib'

  s.add_dependency 'x11-ffi'
end