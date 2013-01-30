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

      class << self 
        def build(mode)
          if mode.kind_of?(self)
            mode
          else
            new(mode)
          end
        end
      end

      def initialize(mode_components = 0)
        @bit_set = BIT_SET_CONFIGURATION.new(mode_components)
      end

      def_delegators :@bit_set,
        :attributes, :state, :[], :enabled_digits, :disabled_digits,
        :read?, :read, :write?, :write, :execute?, :execute?,
        :to_i, :to_s, :hash

    end

  end
end