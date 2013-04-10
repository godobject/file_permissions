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
    # The Mode is basically a bit set consisting of the digits :read, :write
    # and :execute.
    class Mode
      octal_mode = /(?<octal_mode>[0-7])/
      digit_mode = /(?<digit_mode>(?:-|r|w|x){1,3})/
      blank      = /\p{Blank}*?/

      # Regular expression for parsing a Mode from a String representation.
      PATTERN = /^#{blank}(?:#{digit_mode}|#{octal_mode})#{blank}$/

      # Configuration for the GodObject:::BitSet object which is used to handle
      # the state internally.
      BIT_SET_CONFIGURATION = BitSet::Configuration.new(
        read:    'r',
        write:   'w',
        execute: 'x'
      )

      extend Forwardable
      include ModeMixin
      include Comparable

      class << self
        # @!parse include ModeMixin::ClassMethods

        # Creates a new Mode object by parsing a String representation.
        #
        # @param [String] string a String containing a mode
        # @return [GodObject::PosixMode::Mode] a new Mode object
        def parse(string)
          result = string.match(PATTERN)
          
          case 
          when !result
            raise ParserError, 'Invalid format'
          when result[:octal_mode] 
            new(result[:octal_mode].to_i)
          else
            mode_components = []

            result[:digit_mode].scan(/r|w|x/).each do |digit|
              mode_components << :read    if digit == 'r'
              mode_components << :write   if digit == 'w'
              mode_components << :execute if digit == 'x'
            end
            
            if mode_components.uniq!
              raise ParserError,
                "Duplicate digit in: #{string.inspect}"
            end

            new(mode_components)
          end
        end
      end

      # Initializes a new Mode
      #
      # @return [void]
      #
      # @overload initialize(numeric)
      #   @param [Integer] numeric a numeric representation
      #
      # @overload initialize(enabled_digits)
      #   @param [Array<:read, :write, :execute>] enabled_digits a list of
      #     enabled digits
      def initialize(*mode_components)
        @bit_set = BIT_SET_CONFIGURATION.new(*mode_components)
      end

      # @!method enabled_digits
      #   @!attribute [r] enabled_digits
      #   @return [Set<:read, :write, :execute>] a list of all digits which are
      #     enabled
      #
      # @!method disabled_digits
      #   @!attribute [r] disabled_digits
      #   @return [Set<:read, :write, :execute>] a list of all digits which are
      #     disabled
      #
      # @!method state
      #   @!attribute [r] state
      #   @return [{(:read, :write, :execute) => true, false}] a table of all
      #     digits and their states
      #
      # @!parse alias attributes state
      #
      # @!method read?
      #   @!attribute [r] read?
      #   @return [true, false] the current state of the read digit
      #
      # @!parse alias read read?
      #
      # @!method write?
      #   @!attribute [r] write?
      #   @return [true, false] the current state of the write digit
      #
      # @!parse alias write write?
      #
      # @!method execute?
      #   @!attribute [r] execute?
      #   @return [true, false] the current state of the execute digit
      #
      # @!parse alias execute execute?
      #
      # @!method [](digit)
      #   @param [:read, :write, :execute, Integer] digit name or index of a
      #     digit
      #   @return [true, false] current state of the given digit
      #
      # @!method to_i
      #   Represents a Mode as a binary Integer.
      #   @return [Integer] an Integer representation
      #
      # @!method to_s(format)
      #   Represents a Mode as String.
      #   @param [:long, :short] format the String format
      #   @return [String] a String representation
      #
      # @!method hash
      #   @return (see Object#hash) identity hash for hash table usage
      def_delegators :@bit_set,
        :attributes, :state, :[], :enabled_digits, :disabled_digits,
        :read?, :read, :write?, :write, :execute?, :execute,
        :to_i, :to_s, :hash

    end

  end
end
