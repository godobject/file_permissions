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

    # An aggregate of Mode and SpecialMode to represent normal file
    # permissions in a POSIX environment.
    class ComplexMode

      # @return [GodObject::PosixMode::Mode] permissions for the owner
      attr_accessor :user

      # @return [GodObject::PosixMode::Mode] permissions for the owning group
      attr_accessor :group

      # @return [GodObject::PosixMode::Mode] permissions for everyone else
      attr_accessor :other

      # @return [GodObject::PosixMode::SpecialMode] special file flags
      attr_accessor :special

      extend Forwardable
      include HelperMixin

      class << self
        include HelperMixin

        # @overload build(complex_mode)
        #   Returns an existing instance of GodObject::PosixMode::ComplexMode
        #   @param [GodObject::PosixMode::ComplexMode] complex_mode an already
        #     existing ComplexMode
        #   @return [GodObject::PosixMode::ComplexMode] the same ComplexMode
        #      object
        #
        # @overload build(numeric)
        #   Returns a new ComplexMode object with the given numeric
        #   representation.
        #   @param [Integer] numeric a numeric representation
        #   @return [GodObject::PosixMode::ComplexMode] a new ComplexMode object
        #
        # @overload build(enabled_digits)
        #   Returns a new ComplexMode object with the given enabled digits
        #   @param [Array<:user_read, :user_write, :user_execute,
        #     :group_read, :group_write, :group_execute, :other_read,
        #     :other_write, :other_execute, :setuid, :setgid, :sticky>]
        #     enabled_digits a list of enabled digits
        #   @return [GodObject::PosixMode::ComplexMode] a new ComplexMode object
        def build(mode)
          if mode.kind_of?(self)
            mode
          else
            new(mode)
          end
        end

        # Creates a new complex mode from filesystem object given by path.
        #
        # @param [Pathname, String] path path of the source filesystem object
        # @param [:resolve_symlinks, :target_symlinks] symlink_handling if set
        #   to :target_symlinks and the target is a symlink, the symlink will
        #   not be resolved but is itself used as source. By default, the
        #   symlink will be resolved
        def from_file(path, symlink_handling = :resolve_symlinks)
          file = to_pathname(path)

          case symlink_handling
          when :resolve_symlinks
            new(file.stat.mode)
          when :target_symlinks
            new(file.lstat.mode)
          else
            raise ArgumentError, "Invalid symlink handling: #{symlink_handling.inspect}"
          end
        end
      end

      # @overload initialize(numeric)
      #   Returns a new ComplexMode object with the given numeric
      #   representation.
      #   @param [Integer] numeric a numeric representation
      #   @return [GodObject::PosixMode::ComplexMode] a new ComplexMode object
      #
      # @overload initialize(enabled_digits)
      #   Returns a new ComplexMode object with the given enabled digits
      #   @param [Array<:user_read, :user_write, :user_execute, :group_read,
      #     :group_write, :group_execute, :other_read, :other_write,
      #     :other_execute, :setuid, :setgid, :sticky>] enabled_digits a list
      #     of enabled digits
      #   @return [GodObject::PosixMode::ComplexMode] a new ComplexMode object
      def initialize(*mode_components)
        sub_mode_components = Hash.new{|hash, key| hash[key] = Set.new }

        if mode_components.size == 1 && mode_components.first.respond_to?(:to_int)
          integer = mode_components.first

          [:other, :group, :user, :special].each do |mode|
            sub_mode_components[mode] = integer & 0b111
            integer = integer >> 3 unless mode == :special
          end
        else
          if mode_components.size == 1 && mode_components.first.is_a?(Enumerable)
            mode_components = mode_components.first
          end

          mode_components.flatten.each do |digit|
            case digit
            when /^user_(.*)$/
              sub_mode_components[:user] << $1.to_sym
            when /^group_(.*)$/
              sub_mode_components[:group] << $1.to_sym
            when /^other_(.*)$/
              sub_mode_components[:other] << $1.to_sym
            else
              sub_mode_components[:special] << digit
            end
          end
        end

        @user    = Mode.new(sub_mode_components[:user])
        @group   = Mode.new(sub_mode_components[:group])
        @other   = Mode.new(sub_mode_components[:other])
        @special = SpecialMode.new(sub_mode_components[:special])
      end

      # Assigns the mode to a filesystem object given by path.
      #
      # @param [Pathname, String] path path of the target filesystem object
      # @param [:resolve_symlinks, :target_symlinks] symlink_handling if set to
      #   :target_symlinks and the target is a symlink, the symlink will not be
      #   resolved but is itself used as target. By default, the symlink will
      #   be resolved
      def assign_to_file(path, symlink_handling = :resolve_symlinks)
        file = to_pathname(path)

        case symlink_handling
        when :resolve_symlinks
          file.chmod(to_i)
        when :target_symlinks
          begin
            file.lchmod(to_i)
          rescue ::NotImplementedError, Errno::ENOSYS
            raise NotImplementedError, "lchmod function is not available in current OS or Ruby environment"
          end
        else
          raise ArgumentError, "Invalid symlink handling: #{symlink_handling.inspect}"
        end
      end

      # Represents the ComplexMode as String for debugging.
      #
      # @return [String] a String representation for debugging
      def inspect
        "#<#{self.class}: #{to_s.inspect}>"
      end

      # Represents the ComplexMode as String.
      #
      # Uses the format used by the `ls` utility.
      #
      # @return [String] a String representation
      def to_s
        string = ''

        string << case [@special.setuid?, @user.execute?]
                  when [true, true]
                    @user.to_s[0..1] << 's'
                  when [true, false]
                    @user.to_s[0..1] << 'S'
                  else
                    @user.to_s
                  end

        string << case [@special.setgid?, @group.execute?]
                  when [true, true]
                    @group.to_s[0..1] << 's'
                  when [true, false]
                    @group.to_s[0..1] << 'S'
                  else
                    @group.to_s
                  end

        string << case [@special.sticky?, @other.execute?]
                  when [true, true]
                    @other.to_s[0..1] << 't'
                  when [true, false]
                    @other.to_s[0..1] << 'T'
                  else
                    @other.to_s
                  end

        string
      end

      # Converts the ComplexMode to a four-digit octal representation
      #
      # @return [Integer] four-digit octal representation
      def to_i
        result = 0

        [@special, @user, @group, @other].each do |mode|
          result = (result << 3) | mode.to_i
        end

        result
      end

      # @!method setuid
      #   @attribute setuid [readonly]
      #   @return (see GodObject::PosixMode::SpecialMode#setuid)
      #
      # @!method setuid?
      #   @attribute setuid? [readonly]
      #   @return (see GodObject::PosixMode::SpecialMode#setuid?)
      #
      # @!method setgid
      #   @attribute setgid [readonly]
      #   @return (see GodObject::PosixMode::SpecialMode#setgid)
      #
      # @!method setgid?
      #   @attribute setgid? [readonly]
      #   @return (see GodObject::PosixMode::SpecialMode#setgid?)
      #
      # @!method sticky
      #   @attribute sticky [readonly]
      #   @return (see GodObject::PosixMode::SpecialMode#sticky)
      #
      # @!method sticky?
      #   @attribute sticky? [readonly]
      #   @return (see GodObject::PosixMode::SpecialMode#sticky?)
      def_delegators :@special, :setuid?, :setgid?, :sticky?

    end

  end
end
