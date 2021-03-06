require_relative 'lib/version'

Gem::Specification.new do |s|
  s.name          = 'xlib-objects'
  s.version       = XlibObj::VERSION
  s.license       = 'MIT'

  s.summary       = 'A light object wrapper around xlib'
  s.description   = 'Ruby bindings for X11'

  s.authors       = ['Christopher Aue']
  s.email         = 'mail@christopheraue.net'
  s.homepage      = 'https://github.com/christopheraue/ruby-xlib-objects'

  s.files         = Dir.glob('lib/**/*.rb')
  s.require_paths = ['lib']

  s.add_runtime_dependency 'xlib', '~> 1.2'
  s.add_runtime_dependency 'xlib-xinput2', '~> 1.0'

  s.add_development_dependency 'rspec', '~> 3.4'
  s.add_development_dependency 'rspec-its', '~> 1.1'
  s.add_development_dependency 'rspec-mocks-matchers-send_message', '~> 0.1'
end