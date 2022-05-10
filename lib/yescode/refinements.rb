module Refinements
  SNAKE_CASE_REGEX = /\B([A-Z])/

  refine String do
    def snake_case
      gsub(SNAKE_CASE_REGEX, '_\1').downcase
    end

    def camel_case
      first, *rest = split("_")

      "#{first}#{rest.map(&:capitalize).join}"
    end

    def pascal_case
      split("_").map(&:capitalize).join
    end
  end
end
