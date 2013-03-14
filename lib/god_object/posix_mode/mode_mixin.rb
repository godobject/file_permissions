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

    # Common functionality of both Mode and SpecialMode
    module ModeMixin

      # Hook for automatic inclusion of the ClassMethods mixin
      # @private
      def self.included(base)
        base.extend ClassMethods
      end

      # Class mixin for Mode and SpecialMode
      module ClassMethods

        # Either passes through or generates a new Mode object
        #
        # @return [GodObject::PosixMode::ModeMixin]
        #
        # @overload build(mode)
        #   @param [GodObject::PosixMode::ModeMixin] mode an already existing
        #     Mode
        #
        # @overload build(numeric)
        #   @param [Integer] numeric a numeric representation
        #
        # @overload build(enabled_digits)
        #   @param [Array<Symbol>] enabled_digits a list of enabled digits
        def build(mode)
          if mode.kind_of?(self)
            mode
          else
            new(mode)
          end
        end

      end

      # @return [GodObject::PosixMode::ModeMixin] a new Mode with all digit
      #   states inverted
      def invert
        self.class.new(disabled_digits)
      end

      # @param [GodObject::PosixMode::ModeMixin, Array<Symbol>] other another
      #   Mode
      # @return [GodObject::PosixMode::ModeMixin] a new Mode with the enabled
      #   digits of the current and other
      def +(other)
        other = other.enabled_digits if other.respond_to?(:enabled_digits)

        self.class.new(enabled_digits + other)
      end

      # @param [GodObject::PosixMode::ModeMixin, Array<Symbol>] other another
      #   Mode
      # @return [GodObject::PosixMode::ModeMixin] a new Mode with the enabled
      #   digits of the current without the enabled digits of other
      def -(other)
        other = other.enabled_digits if other.respond_to?(:enabled_digits)

        self.class.new(enabled_digits - other)
      end

      # @param [GodObject::PosixMode::ModeMixin, Integer] other another Mode
      # @return [GodObject::PosixMode::ModeMixin] a new Mode with the enabled
      #   digits of the current and other
      def union(other)
        other = other.to_i if other.respond_to?(:to_i)

        self.class.new(to_i | other)
      end

      alias | union

      # @param [GodObject::PosixMode::ModeMixin, Integer] other another Mode
      # @return [GodObject::PosixMode::ModeMixin] a new Mode with only those
      #   digits enabled which are enabled in both the current and other
      def intersection(other)
        other = other.to_i if other.respond_to?(:to_i)

        self.class.new(to_i & other)
      end

      alias & intersection

      # @param [GodObject::PosixMode::ModeMixin, Integer] other another Mode
      # @return [GodObject::PosixMode::ModeMixin] a new Mode with the enabled
      #   digits which are enabled in only one of current and other
      def symmetric_difference(other)
        other = other.to_i if other.respond_to?(:to_i)

        self.class.new(to_i ^ other)
      end

      alias ^ symmetric_difference

      # Compares the Mode to another to determine its relative position.
      #
      # Relative position is defined by comparing the Integer representation.
      #
      # @note Only other Modes or Integer-likes are considered comparable.
      #
      # @param [Object] other other Object to be compared
      #   object
      # @return [-1, 0, 1, nil] -1 if other is greater, 0 if other is equal and
      #   1 if other is lesser than self, nil if comparison is impossible
      def <=>(other)
        to_i <=> other.to_i
      rescue NoMethodError
        nil
      end

      # Answers if another object is equal and of the same type family.
      #
      # @see GodObject::PosixMode::ModeMixin#<=>
      # @param [Object] other an object to be checked for equality
      # @return [true, false] true if the object is considered equal and of the
      #   same type family, false otherwise
      def eql?(other)
        self == other && other.kind_of?(self.class)
      end

      # Represents a Mode as String for debugging.
      #
      # @return [String] a String representation for debugging
      def inspect
        "#<#{self.class}: #{to_s.inspect}>"
      end
    end

  end
end
