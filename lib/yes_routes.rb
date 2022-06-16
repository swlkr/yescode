# frozen_string_literal: true

class YesRoutes
  class << self
    attr_accessor :routes, :paths

    def match(verb, path_string, class_name)
      YesRoutes.paths ||= {}
      YesRoutes.paths[class_name] = path_string

      YesRoutes.routes ||= Hash.new { |hash, key| hash[key] = [] }
      YesRoutes.routes[verb] << [path_string, class_name]
    end

    def path(class_name, params = {})
      path_string = paths[class_name]
      coerced_params = coerce_params(params)

      sub_params_in_path(path_string, coerced_params)
    end

    def get(path_string, class_name)
      match("GET", path_string, class_name)
    end

    def post(path_string, class_name)
      match("POST", path_string, class_name)
    end

    def get_post(path_string, klass)
      match("POST", path_string, klass, nil)
    end

    private

    def coerce_params(params)
      case params
      when nil
        {}
      when YesRecord
        params.to_param
      else
        params
      end
    end

    def sub_params_in_path(path, params = {})
      params.transform_keys!(&:inspect)

      re = Regexp.union(params.keys)

      path.gsub(re, params)
    end
  end
end
