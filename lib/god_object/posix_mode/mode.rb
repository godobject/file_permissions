# encoding: UTF-8

module GodObject
  module PosixMode

    class Mode
      octal_mode = /(?<octal_mode>[0-7])/
      digit_mode = /(?<digit_mode>(?:-|r|w|x){1,3})/
      blank      = /\p{Blank}*?/

      PATTERN = /^#{blank}(?:#{digit_mode}|#{octal_mode})#{blank}$/
      BIT_SET_CONFIGURATION = BitSet::Configuration.new(
        read:    'r',
        write:   'w',
        execute: 'x'
      )

      extend Forwardable
      include ModeMixin
      include Comparable

      class << self 
        def build(mode)
          if mode.kind_of?(Mode)
            mode
          else
            new(mode)
          end
        end
        
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

      def initialize(mode_components = 0)
        @bit_set = BIT_SET_CONFIGURATION.new(mode_components)
      end

      def_delegators :@bit_set,
        :attributes, :state, :[], :enabled_digits, :disabled_digits,
        :read?, :read, :write?, :write, :execute?, :execute,
        :to_i, :to_s, :hash

    end

  end
end
