# frozen_string_literal: true

module Yescode
  module Strings
    SNAKE_CASE_REGEX = /\B([A-Z])/

    def snake_case(str)
      str.gsub(SNAKE_CASE_REGEX, '_\1').downcase
    end

    def camel_case(str)
      first, *rest = str.split("_")

      "#{first&.downcase}#{rest.map(&:capitalize).join}"
    end

    def pascal_case(str)
      str.split("_").map(&:capitalize).join
    end

    def class_name
      to_s.split("::").last || ""
    end

    def filename
      snake_case(class_name)
    end
  end
end
