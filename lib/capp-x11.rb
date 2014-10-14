require 'bundler/setup'
require 'X11'

module CappX11; end

require_relative 'display'
require_relative 'screen'
require_relative 'sub_screen'
require_relative 'window'
require_relative 'window/property'
require_relative 'event'