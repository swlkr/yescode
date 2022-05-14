# frozen_string_literal: true

require "yescode/refinements"

module Strings
  def snake_case(str)
    str.gsub(/\B([A-Z])/, '_\1').downcase
  end
end

class YesRoutes
  using Refinements
  class RouteDoesNotExistError < StandardError; end
  class RouteParamsNilError < StandardError; end

  class YesRoute
    attr_accessor :path, :class_name, :method_name

    def initialize(path:, class_name:, method_name:)
      @path = path
      @class_name = class_name
      @method_name = method_name
    end
  end

  class << self
    attr_accessor :routes, :paths

    def match(verb, path, class_name, method_name)
      @paths ||= {}
      @paths[[class_name, method_name]] = path

      @routes ||= Hash.new { |hash, key| hash[key] = [] }
      @routes[verb] << YesRoute.new(path: path, class_name: class_name, method_name: method_name)
    end

    def path(class_name, method_name, params = {})
      path_string = paths[[class_name, method_name]]

      raise RouteParamsNilError, "Route params for :#{class_name}, :#{method_name} cannot be nil" if params.nil?

      params = params.to_param if params.is_a?(YesRecord)

      raise RouteDoesNotExistError, "Route for class #{class_name} and method #{method_name} doesn't exist" unless path_string

      sub_params_in_path(path_string, params)
    end

    def get(path_string, class_name, method_name)
      match("GET", path_string, class_name, method_name)
    end

    def post(path_string, class_name, method_name)
      match("POST", path_string, class_name, method_name)
    end

    def resource(prefix, class_name)
      snake_case = Strings.snake_case(class_name.to_s).gsub(/\B([A-Z])/, '_\1').downcase

      match("GET", full_path(prefix, ""), class_name, :index)
      match("GET", full_path(prefix, "/new"), class_name, :new)
      match("POST", full_path(prefix, "/new"), class_name, :create)
      match("GET", full_path(prefix, "/:#{snake_case}"), class_name, :show)
      match("GET", full_path(prefix, "/:#{snake_case}/edit"), class_name, :edit)
      match("POST", full_path(prefix, "/:#{snake_case}/edit"), class_name, :update)
      match("POST", full_path(prefix, "/:#{snake_case}/delete"), class_name, :delete)
    end

    private

    def full_path(prefix, suffix)
      "#{prefix}#{suffix}".gsub(%r{/+}, "/")
    end

    def sub_params_in_path(path, params = {})
      params.transform_keys!(&:inspect)

      re = Regexp.union(params.keys)

      path.gsub(re, params)
    end
  end
end
