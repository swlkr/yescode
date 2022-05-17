# frozen_string_literal: true

require "yescode/errors"
require "yescode/route"
require "yescode/resource"

class YesRoutes
  class << self
    attr_accessor :routes, :paths

    def match(verb, path, class_name, method_name)
      route = Yescode::Route.new(verb, path, class_name, method_name)
      add_route(route)
    end

    def path(class_name, method_name, params = {})
      path_string = paths[[class_name, method_name]]

      raise Yescode::RouteParamsNilError, "Route params for :#{class_name}, :#{method_name} cannot be nil" if params.nil?

      params = params.to_param if params.is_a?(YesRecord)

      raise Yescode::RouteMissing, "Route for class #{class_name} and method #{method_name} doesn't exist" unless path_string

      sub_params_in_path(path_string, params)
    end

    def get(path_string, class_name, method_name)
      match("GET", path_string, class_name, method_name)
    end

    def post(path_string, class_name, method_name)
      match("POST", path_string, class_name, method_name)
    end

    def resource(prefix, class_name)
      Yescode::Resource.routes(prefix, class_name).each do |route|
        add_route(route)
      end
    end

    private

    def sub_params_in_path(path, params = {})
      params.transform_keys!(&:inspect)

      re = Regexp.union(params.keys)

      path.gsub(re, params)
    end

    def add_route(route)
      @paths ||= {}
      @routes ||= Hash.new { |hash, key| hash[key] = [] }

      @paths[[route.class_name, route.method_name]] = route.path
      @routes[route.verb] << route
    end
  end
end
