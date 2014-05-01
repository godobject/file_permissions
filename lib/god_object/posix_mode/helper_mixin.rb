# encoding: UTF-8
=begin
Copyright GodObject Team <dev@godobject.net>, 2012-2014

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

module GodObject
  module PosixMode

    # Mixin containing helper methods
    #
    # @private
    module HelperMixin

      # @return [Array<Symbol>] possible output String formats
      STRING_FORMAT = Set[:long, :short].freeze

      protected

      # Ensures that input is Pathname
      #
      # @param [Pathname, String] path a path
      # @param [:forbid_nil, :allow_nil] nil_handling if set to :allow_nil,
      #   a nil path will be passed-through. Raises an exception otherwise
      # @return [Pathname] the path as Pathname object
      def to_pathname(path, nil_handling = :forbid_nil)
        return nil if path.nil? if nil_handling == :allow_nil

        path.is_a?(Pathname) ? path : Pathname.new(path)
      end

    end

  end
end
