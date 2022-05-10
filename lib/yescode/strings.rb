# frozen_string_literal: true

module Yescode
  class Strings
    SNAKE_CASE_REGEX = /\B([A-Z])/

    class << self
      def snake_case(str)
        str.gsub(SNAKE_CASE_REGEX, '_\1').downcase
      end

      def camel_case(str)
        return str if !str.include?('_') && str =~ /[A-Z]+.*/

        str.split('_').map(&:capitalize).join
      end

      def pascal_case(str)
        camel_case(str).capitalize
      end
    end
  end
end
