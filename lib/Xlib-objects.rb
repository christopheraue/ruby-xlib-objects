require 'bundler/setup'
Bundler.require(:default)

module XlibObj; end

require_relative 'atom'
require_relative 'display'
require_relative 'event'
require_relative 'event/client_message'
require_relative 'screen'
require_relative 'screen/crtc'
require_relative 'screen/crtc/output'
require_relative 'window'
require_relative 'window/property'
require_relative 'window/event_handler'
