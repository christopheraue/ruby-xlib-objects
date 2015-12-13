#
# Copyright (c) 2014 Christopher Aue <mail@christopheraue.net>
#
# This file is part of the ruby xlib-objects gem. It is subject to the license
# terms in the LICENSE file found in the top-level directory of this
# distribution and at http://github.com/christopheraue/ruby-xlib-objects.
#

require 'xlib'
require 'xlib/xinput2'

module XlibObj; end

lib_dir = File.dirname __FILE__
lib_files = File.join(lib_dir, '**/*.rb')

Dir[lib_files].sort.each { |f| require f }
