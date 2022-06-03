# frozen_string_literal: true

module Yescode
  class RouteNotFound < StandardError; end
  class RouteClassDoesNotExist < StandardError; end
  class RouteMethodDoesNotExist < StandardError; end
  class NotFoundError < StandardError; end
  class ServerError < StandardError; end

  class Router
    class << self
      attr_accessor :logger, :assets
    end

    def initialize(routes)
      @routes = routes
      @logger = self.class.logger
    end

    def call(env)
      request = Rack::Request.new(env)
      route, params = find_route(request.request_method, request.path_info)

      raise RouteNotFound unless route

      env["params"] = params&.merge(request.params)&.transform_keys(&:to_sym) || {}
      _, class_name, method = route
      klass = nil
      begin
        klass = Object.const_get(class_name)
      rescue NameError => e
        raise RouteClassDoesNotExist, e.message
      end
      controller = klass.new(env)
      raise RouteMethodDoesNotExist, "#{class_name}##{method} does not exist" unless controller.respond_to?(method)

      @logger&.info(msg: "Request dispatched", route: "#{class_name}##{method}", params: env["params"])
      klass.before_actions&.each do |before_action|
        controller.send(before_action)
      end
      response = controller.public_send(method)
      raise NotFoundError if response.nil?

      case response
      when YesView
        controller.render response
      else
        response
      end
    rescue NotFoundError, RouteNotFound
      raise if Env.development?

      [404, { "content-type" => "text/html" }, File.open("public/404.html")]
    rescue StandardError
      raise if Env.development?

      [500, { "content-type" => "text/html" }, File.open("public/500.html")]
    end

    private

    def find_route(request_method, path_info)
      params = {}
      route = YesRoutes.routes[request_method].find do |r|
        found_path = Regexp.new("^#{r.first.gsub(/:(\w+)/, '(?<\1>[a-zA-Z0-9_\-=]+)')}$")
        params = path_info.match(found_path)&.named_captures
      end

      [route, params]
    end
  end
end
