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
        other = other.to_i if other.respond_to?(:to_i)

        self.class.new(to_i & other)
      end

      alias & intersection

      def union(other)
        other = other.to_i if other.respond_to?(:to_i)

        self.class.new(to_i | other)
      end

      alias | union

      def symmetric_difference(other)
        other = other.to_i if other.respond_to?(:to_i)

        self.class.new(to_i ^ other)
      end

      alias ^ symmetric_difference

      def <=>(other)
        to_i <=> other.to_i
      rescue NoMethodError
        nil
      end

      def eql?(other)
        self == other && other.kind_of?(self.class)
      end

      def inspect
        "#<#{self.class}: #{to_s.inspect}>"
      end
    end

  end
end
