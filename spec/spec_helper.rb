require_relative '../lib/xlib-objects'
require 'rspec'
require 'rspec/its'

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

RSpec.configure do |config|
  config.before(:suite) do
    # stub Xlib methods
    def Xlib.method_missing; nil end
  end
end

def verify_partial_doubles_on
  RSpec.configure do |config|
    config.mock_with :rspec do |mocks|
      mocks.verify_partial_doubles = true
    end
  end
end

def verify_partial_doubles_off
  RSpec.configure do |config|
    config.mock_with :rspec do |mocks|
      mocks.verify_partial_doubles = false
    end
  end
end
