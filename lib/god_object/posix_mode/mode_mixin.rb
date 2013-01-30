# encoding: UTF-8

module GodObject
  module PosixMode

    module ModeMixin
      def invert
        self.class.new(disabled_digits)
      end

      def +(other)
        other = other.enabled_digits if other.respond_to?(:enabled_digits)

        self.class.new(enabled_digits + other)
      end

      def -(other)
        other = other.enabled_digits if other.respond_to?(:enabled_digits)

        self.class.new(enabled_digits - other)
      end

      def intersection(other)
        other = other.state if other.respond_to?(:state)

        self.class.new(state & other)
      end

      alias & intersection

      def union(other)
        other = other.state if other.respond_to?(:state)

        self.class.new(state | other)
      end

      alias | union

      def symmetric_difference(other)
        other = other.state if other.respond_to?(:state)

        self.class.new(state ^ other)
      end

      alias ^ symmetric_difference

      def <=>(other)
        state <=> other.state
      rescue NoMethodError
        nil
      end

      def inspect
        "#<#{self.class}: #{to_s.inspect}>"
      end
    end

  end
end