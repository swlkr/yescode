# frozen_string_literal: true

module Yescode
  module Strings
    SNAKE_CASE_REGEX = /\B([A-Z])/

    def snake_case(str)
      str.gsub(SNAKE_CASE_REGEX, '_\1').downcase
    end

    def camel_case(str)
      result = pascal_case(str)
      result[0] = result[0].downcase

      result
    end

    def pascal_case(str)
      str.split("_").map(&:capitalize).join
    end
  end
end
