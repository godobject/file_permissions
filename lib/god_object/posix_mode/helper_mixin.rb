# encoding: UTF-8

module GodObject
  module PosixMode

    module HelperMixin
      STRING_FORMAT = Set[:long, :short].freeze

      protected

      def to_pathname(path, options = nil)
        return nil if path.nil? if options == :allow_nil

        path.is_a?(Pathname) ? path : Pathname.new(path)
      end

    end

  end
end
