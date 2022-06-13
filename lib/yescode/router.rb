# frozen_string_literal: true

module Yescode
  class RouteNotFound < StandardError; end
  class RouteUndefined < StandardError; end
  class NotFoundError < StandardError; end
  class ServerError < StandardError; end

  class Router
    class << self
      attr_accessor :logger
    end

    def call(env)
      request = Rack::Request.new(env)
      route, params = find_route(request.request_method || "", request.path_info || "")
      _, class_name, method = route

      raise RouteUndefined, "#{request.request_method} #{request.path_info} is not defined" unless route_defined?(class_name, method)

      env["params"] = params&.merge(request.params)&.transform_keys(&:to_sym) || {}
      klass = Object.const_get(class_name) unless class_name.nil?
      controller = klass.new(env)
      klass.before_actions&.each do |before_action|
        controller.send(before_action)
      end
      self.class.logger&.info(msg: "Request dispatched", route: "#{class_name}##{method}", params: env["params"])
      response = controller.public_send(method)

      case response
      when YesView
        controller.render response
      when nil
        raise NotFoundError
      else
        response
      end
    rescue NotFoundError, RouteUndefined
      raise if Env.development?

      [404, { "content-type" => "text/html" }, File.open("public/404.html")]
    rescue StandardError
      raise if Env.development?

      [500, { "content-type" => "text/html" }, File.open("public/500.html")]
    end

    private

    def find_route(request_method, path_info)
      params = nil || { "" => nil, "_" => "" } # use value as a type for steep?
      routes = YesRoutes.routes[request_method] || []
      route = routes.find do |route_path,|
        path_regex = Regexp.new("^#{route_path.gsub(/:(\w+)/, '(?<\1>[a-zA-Z0-9_\-=]+)')}$")
        params = path_info.match(path_regex)&.named_captures
      end

      [route, params]
    end

    def route_defined?(class_name, method_name)
      return false if class_name.nil?

      Object.const_get(class_name).method_defined?(method_name)
    rescue NameError => _e
      false
    end
  end
end
