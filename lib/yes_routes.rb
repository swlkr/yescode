# frozen_string_literal: true

class YesRoutes
  class << self
    attr_accessor :routes, :paths

    def route(path_string, class_name)
      YesRoutes.paths ||= {}
      YesRoutes.paths[class_name] = path_string

      YesRoutes.routes ||= []
      YesRoutes.routes << [path_string, class_name]
    end

    def path(class_name, params = {})
      path_string = paths[class_name]
      coerced_params = coerce_params(params)

      sub_params_in_path(path_string, coerced_params)
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
