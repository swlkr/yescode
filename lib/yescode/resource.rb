# frozen_string_literal: true

require "yescode/strings"
require "yescode/route"

module Yescode
  module Resource
    extend Strings

    def self.routes(prefix, class_name)
      segment = snake_case(class_name.to_s)

      [
        ["GET", "/", :index],
        ["GET", "/new", :new],
        ["POST", "/new", :create],
        ["GET", "/:#{segment}", :show],
        ["GET", "/:#{segment}/edit", :edit],
        ["GET", "/:#{segment}/edit", :update],
        ["GET", "/:#{segment}/delete", :delete]
      ].map do |verb, suffix, method_name|
        path = path(prefix, suffix)

        Route.new(verb, path, class_name, method_name)
      end
    end

    def path(prefix, suffix)
      "#{prefix}/#{suffix}".gsub(%r{/+}, "/")
    end
  end
end
