require 'bundler/setup'

module Xlib; end

require_relative 'capi/init'
require_relative 'display'
require_relative 'screen'
require_relative 'window'
require_relative 'window/property'