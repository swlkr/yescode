# frozen_string_literal: true

class YesRoutes
  using Refinements
  class RouteDoesNotExistError < StandardError; end
  class RouteParamsNilError < StandardError; end

  class << self
    attr_accessor :routes, :paths

    def match(verb, path_string, class_name, method_name)
      @paths ||= {}
      @paths[[class_name, method_name]] = path_string

      @routes ||= Hash.new { |hash, key| hash[key] = [] }
      @routes[verb] << [path_string, class_name, method_name]
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

    def resource(path_string, class_name)
      snake_case = class_name.snake_case
      [
        [:get, "index", ""],
        [:get, "new", "/new"],
        [:post, "create", "/new"],
        [:get, "show", "/:#{snake_case}"],
        [:get, "edit", "/:#{snake_case}/edit"],
        [:post, "update", "/:#{snake_case}/edit"],
        [:post, "delete", "/:#{snake_case}/edit"]
      ].each do |method, method_name, suffix|
        public_send(method, [path_string, suffix].join("/").gsub(%r{/+}, "/"), class_name, method_name)
      end
    end

    private

    def sub_params_in_path(path, params = {})
      params.transform_keys!(&:inspect)

      re = Regexp.union(params.keys)

      path.gsub(re, params)
    end
  end
end
