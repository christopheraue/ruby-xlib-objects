require_relative '../lib/xlib'
require 'factory_girl'

Dir['./spec/mixin/**/*.rb'].sort.each { |f| require f }
Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end

I18n.enforce_available_locales = false
