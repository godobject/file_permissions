# encoding: UTF-8
=begin
Copyright Alexander E. Fischer <aef@raxys.net>, 2012-2013

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

    # Represents one component of the normal file mode in POSIX environments.
    #
    # The SpecialMode is basically a bit set consisting of the digits :setuid,
    # :setgid and :sticky.
    class SpecialMode
      octal_mode = /(?<octal_mode>[0-7])/
      digit_mode = /(?<digit_mode>(?:-|s){2}(?:-|t))/
      blank      = /\p{Blank}*?/

      # Regular expression for parsing a SpecialMode from a String representation.
      PATTERN = /^#{blank}(?:#{digit_mode}|#{octal_mode})#{blank}$/

      # Configuration for the GodObject:::BitSet object which is used to handle
      # the state internally.
      BIT_SET_CONFIGURATION = BitSet::Configuration.new(
        setuid: 's',
        setgid: 's',
        sticky: 't'
      )

      extend Forwardable
      include ModeMixin
      include Comparable

      class << self
        # @!parse include ModeMixin::ClassMethods

        # Creates a new SpecialMode object by parsing a String representation.
        #
        # @param [String] string a String containing a mode
        # @return [GodObject::PosixMode::SpecialMode] a new SpecialMode object
        def parse(string)
          result = string.match(PATTERN)

          case
          when !result
            raise ParserError, 'Invalid format'
          when result[:octal_mode]
            new(result[:octal_mode].to_i)
          else
            mode_components = []

            mode_components << :setuid if result[:digit_mode][0] == 's'
            mode_components << :setgid if result[:digit_mode][1] == 's'
            mode_components << :sticky if result[:digit_mode][2] == 't'

            new(mode_components)
          end
        end
      end

      # Initializes a new SpecialMode
      #
      # @return [void]
      #
      # @overload initialize(numeric)
      #   @param [Integer] numeric a numeric representation
      #
      # @overload initialize(enabled_digits)
      #   @param [Array<:setuid, :setgid, :sticky>] enabled_digits a list of
      #     enabled digits
      def initialize(*mode_components)
        @bit_set = BIT_SET_CONFIGURATION.new(*mode_components)
      end

      # @!method enabled_digits
      #   @!attribute [r] enabled_digits
      #   @return [Set<:setuid, :setgid, :sticky>] a list of all digits which
      #     are enabled
      #
      # @!method disabled_digits
      #   @!attribute [r] disabled_digits
      #   @return [Set<:setuid, :setgid, :sticky>] a list of all digits which
      #     are disabled
      #
      # @!method state
      #   @!attribute [r] state
      #   @return [{(:read, :write, :execute) => true, false}] a table of all
      #     digits and their states
      #
      # @!method setuid?
      #   @!attribute [r] setuid?
      #   @return [true, false] the current state of the setuid digit
      #
      # @!parse alias setuid setuid?
      #
      # @!method setgid?
      #   @!attribute [r] setgid?
      #   @return [true, false] the current state of the setgid digit
      #
      # @!parse alias setgid setgid?
      #
      # @!method sticky?
      #   @attribute [r] sticky?
      #   @return [true, false] the current state of the sticky digit
      #
      # @!parse alias sticky sticky?
      #
      # @!method [](digit)
      #   @param [:setuid, :setgid, :sticky, Integer] digit name or index of a
      #     digit
      #   @return [true, false] current state of the given digit
      #
      # @!method to_i
      #   Represents a SpecialMode as a binary Integer.
      #   @return [Integer] an Integer representation
      #
      # @!method to_s(format)
      #   Represents a SpecialMode as String.
      #   @param [:long, :short] format the String format
      #   @return [String] a String representation
      #
      # @!method hash
      #   @return (see Object#hash) identity hash for hash table usage
      def_delegators :@bit_set,
        :attributes, :state, :[], :enabled_digits, :disabled_digits,
        :setuid?, :setuid, :setgid?, :setgid, :sticky?, :sticky,
        :to_i, :to_s, :hash

    end

  end
end
