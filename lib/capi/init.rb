require 'ffi'

module Xlib::Capi
  extend FFI::Library
  ffi_lib 'X11'
end

require_relative 'types'
require_relative 'functions'
