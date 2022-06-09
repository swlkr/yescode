# frozen_string_literal: true

class YesRoutes
  class << self
    attr_accessor :routes, :paths

    def match(verb, path_string, class_name, method_name)
      YesRoutes.paths ||= {}
      YesRoutes.paths[[class_name, method_name]] = path_string

      YesRoutes.routes ||= Hash.new { |hash, key| hash[key] = [] }
      YesRoutes.routes[verb] << [path_string, class_name, method_name]
    end

    def path(class_name, method_name, params = {})
      path_string = paths[[class_name, method_name]]
      raise(Yescode::RouteUndefined, "#{method_name} is not defined in class #{class_name}") unless path_string

      params = case params
               when nil
                 {}
               when YesRecord
                 params.to_param
               else
                 params
               end

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
      match("GET", full_path(path_string, ""), class_name, :index)
      match("GET", full_path(path_string, "/new"), class_name, :new)
      match("POST", full_path(path_string, "/new"), class_name, :create)
      match("GET", full_path(path_string, "/:id"), class_name, :show)
      match("GET", full_path(path_string, "/:id/edit"), class_name, :edit)
      match("POST", full_path(path_string, "/:id/edit"), class_name, :update)
      match("POST", full_path(path_string, "/:id/delete"), class_name, :delete)
    end

    def resources(path_string, class_name)
      raise StandardError, "Needs at least two url segments" if path_string.split("/").size < 2
      raise StandardError, "The last url segment needs to be a param" unless path_string.split("/").last&.include?(":")

      *prefix, _ = path_string.split("/")
      prefix = prefix.join("/")

      match("GET", full_path(prefix, ""), class_name, :index)
      match("GET", full_path(prefix, "/new"), class_name, :new)
      match("POST", full_path(prefix, "/new"), class_name, :create)
      match("GET", full_path(path_string, ""), class_name, :show)
      match("GET", full_path(path_string, "/edit"), class_name, :edit)
      match("POST", full_path(path_string, "/edit"), class_name, :update)
      match("POST", full_path(path_string, "/delete"), class_name, :delete)
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
