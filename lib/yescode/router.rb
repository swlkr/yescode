# frozen_string_literal: true

module Yescode
  class RouteNotFound < StandardError; end
  class RouteClassDoesNotExist < StandardError; end
  class RouteMethodDoesNotExist < StandardError; end
  class NotFoundError < StandardError; end
  class ServerError < StandardError; end

  class Router
    class << self
      attr_accessor :logger
    end

    def initialize(app, routes)
      @app = app
      @routes = routes
      @logger = self.class.logger
    end

    def call(env)
      path_info = env[Rack::PATH_INFO]
      request_method = env[Rack::REQUEST_METHOD]
      params = {}
      route = @routes[request_method].find do |r|
        path = Regexp.new("^#{r.first.gsub(/:(\w+)/, '(?<\1>[a-zA-Z0-9_\-=]+)')}$")
        params = path_info.match(path)&.named_captures
      end

      raise RouteNotFound unless route

      params.merge!(env[Rack::RACK_REQUEST_FORM_HASH] || {})
            .transform_keys!(&:to_sym)
      env["params"] = params
      _, class_name, method = route
      klass = nil
      begin
        klass = Object.const_get(class_name)
      rescue NameError => e
        raise RouteClassDoesNotExist, e.message
      end
      obj = klass.new(env)
      raise RouteMethodDoesNotExist, "#{class_name}##{method} does not exist" unless obj.respond_to?(method)

      @logger&.info(msg: "Request dispatched", route: "#{class_name}##{method}", params: params.except(:_csrf))
      klass.before_actions&.each do |before_action|
        obj.send(before_action)
      end
      response = obj.public_send(method)
      raise NotFoundError if response.nil?

      case response
      when YesView
        response.csrf_name = obj.csrf_name
        response.csrf_value = obj.csrf_value
        response.assets = @app.assets.to_h
        response.session = obj.session
        response.ajax = env.key?("HTTP_YES_AJAX")
        layout = klass.layout
        content = response.render(response.template)
        content = response.render(layout.template, content:) if layout && response.class < layout.class
        obj.ok content
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
  end
end
