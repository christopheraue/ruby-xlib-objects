#
# Copyright (c) 2014 Christopher Aue <mail@christopheraue.net>
#
# This file is part of the ruby xlib-objects gem. It is subject to the license
# terms in the LICENSE file found in the top-level directory of this
# distribution and at http://github.com/christopheraue/ruby-xlib-objects.
#

require 'xlib'

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
