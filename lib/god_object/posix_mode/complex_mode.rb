# encoding: UTF-8

module GodObject
  module PosixMode

    class ComplexMode
      attr_accessor :special, :user, :group, :other

      class << self
        include HelperMixin

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

      def initialize(mode_components = 0)
        sub_mode_components = Hash.new{|hash, key| hash[key] = Set.new }

        if mode_components.respond_to?(:to_int)
          [:other, :group, :user, :special].each do |mode|
            sub_mode_components[mode] = mode_components & 0b111
            mode_components = mode_components >> 3 unless mode == :special
          end
        else
          mode_components.each do |digit|
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

      def assign_to_file(path, symlink_handling = :resolve_symlinks)
        file = to_pathname(path)

        case symlink_handling
        when :resolve_symlinks
          file.chmod(to_i)
        when :target_symlinks
          file.lchmod(to_i)
        else
          raise ArgumentError, "Invalid symlink handling: #{symlink_handling.inspect}"
        end
      end

      def inspect
        "#<#{self.class}: #{to_s.inspect}>"
      end

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

      def to_i
        result = 0

        [@special, @user, @group, @other].each do |mode|
          result = (result << 3) | mode.to_i
        end

        result
      end

    end

  end
end
