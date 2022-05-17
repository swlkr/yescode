# frozen_string_literal: true

class YesRoutes
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
      [
        ["GET", :index, ""],
        ["GET", :new, "/new"],
        ["POST", :create, "/new"],
        ["GET", :show, "/:id"],
        ["GET", :edit, "/:id/edit"],
        ["POST", :update, "/:id/edit"],
        ["POST", :delete, "/:id/delete"]
      ].each do |method, method_name, suffix|
        match(method, full_path(path_string, suffix), class_name, method_name)
      end
    end

    private

    def sub_params_in_path(path, params = {})
      params.transform_keys!(&:inspect)

      re = Regexp.union(params.keys)

      path.gsub(re, params)
    end

    def full_path(prefix, suffix)
      "#{prefix}/#{suffix}".gsub(%r{/+}, "/").chomp("/")
    end
  end
end
