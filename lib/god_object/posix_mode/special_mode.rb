# encoding: UTF-8

module GodObject
  module PosixMode

    class SpecialMode
      BIT_SET_CONFIGURATION = BitSet::Configuration.new(
        setuid: 's',
        setgid: 's',
        sticky: 't'
      )

      extend Forwardable
      include ModeMixin
      include Comparable

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
