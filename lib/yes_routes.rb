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

    def action(path_string, class_name)
      match("GET", path_string, class_name, :new)
      match("POST", path_string, class_name, :create)
    end

    def actions(path_string, class_name)
      match("GET", path_string, class_name, :show)
      match("GET", "#{path_string}/new", class_name, :new)
      match("POST", "#{path_string}/new", class_name, :create)
      match("GET", "#{path_string}/edit", class_name, :edit)
      match("POST", "#{path_string}/edit", class_name, :update)
      match("POST", "#{path_string}/delete", class_name, :delete)
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

    def resources(path_string, class_name)
      raise StandardError, "Needs at least two url segments" if path_string.split("/").size < 2
      raise StandardError, "The last url segment needs to be a param" unless path_string.split("/").last.include?(":")

      *prefix, _ = path_string.split("/")
      prefix = prefix.join("/")

      [
        ["GET", :index, "", :plural],
        ["GET", :new, "/new", :plural],
        ["POST", :create, "/new", :plural],
        ["GET", :show, ""],
        ["GET", :edit, "/edit"],
        ["POST", :update, "/edit"],
        ["POST", :delete, "/delete"]
      ].each do |method, method_name, suffix, plural|
        if plural
          match(method, full_path(prefix, suffix), class_name, method_name)
        else
          match(method, full_path(path_string, suffix), class_name, method_name)
        end
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
