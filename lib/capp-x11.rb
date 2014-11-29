require 'bundler/setup'
require 'X11'

module CappX11; end

require_relative 'atom'
require_relative 'display'
require_relative 'screen'
require_relative 'screen/crtc'
require_relative 'screen/crtc/output'
require_relative 'window'
require_relative 'window/property'
require_relative 'window/event_handler'
require_relative 'event'