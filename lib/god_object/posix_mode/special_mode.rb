# encoding: UTF-8

module GodObject
  module PosixMode

    class SpecialMode
      octal_mode = /(?<octal_mode>[0-7])/
      digit_mode = /(?<digit_mode>(?:-|s){2}(?:-|t))/
      blank      = /\p{Blank}*?/

      PATTERN = /^#{blank}(?:#{digit_mode}|#{octal_mode})#{blank}$/
      BIT_SET_CONFIGURATION = BitSet::Configuration.new(
        setuid: 's',
        setgid: 's',
        sticky: 't'
      )

      extend Forwardable
      include ModeMixin
      include Comparable

      class << self
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

      def initialize(mode_components = 0)
        @bit_set = BIT_SET_CONFIGURATION.new(mode_components)
      end

      def_delegators :@bit_set,
        :attributes, :state, :[], :enabled_digits, :disabled_digits,
        :setuid?, :setuid, :setgid?, :setgid, :sticky?, :sticky,
        :to_i, :to_s, :hash

    end

  end
end
