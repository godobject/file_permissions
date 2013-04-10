# encoding: UTF-8
=begin
Copyright GodObject Team <dev@godobject.net>, 2012-2013

This file is part of PosixMode.

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
PERFORMANCE OF THIS SOFTWARE.
=end

require 'set'
require 'forwardable'
require 'bit_set'

# Namespace for projects of the GodObject team <dev@godobject.net>.
#
# If you want to be able to simply type Example instead of GodObject::Example
# to address classes in this namespace simply write the following before using
# the classes.
#
# @example Including the namespace
#   include GodObject
# @see https://www.godobject.net/
module GodObject

  # Namespace for components of the "posix_mode" library
  module PosixMode

  end

end

require 'god_object/posix_mode/helper_mixin'
require 'god_object/posix_mode/version'
require 'god_object/posix_mode/exceptions'
require 'god_object/posix_mode/mode_mixin'
require 'god_object/posix_mode/mode'
require 'god_object/posix_mode/special_mode'
require 'god_object/posix_mode/complex_mode'
