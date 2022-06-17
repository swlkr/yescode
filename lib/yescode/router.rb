# frozen_string_literal: true

module Yescode
  class NotFoundError < StandardError; end
  class ServerError < StandardError; end

  class Router
    class << self
      attr_accessor :logger
    end

    def call(env)
      request = Rack::Request.new(env)
      klass, params = find_route(request.path_info || "")
      raise NotFoundError unless klass

      env["params"] = params&.merge(request.params)&.transform_keys(&:to_sym) || {}
      component = klass.new(env)
      klass.before_actions&.each do |before_action|
        component.send(before_action)
      end
      self.class.logger&.info(msg: "Request dispatched", component: component.class.to_s, params: env["params"])
      component.call
      raise NotFoundError unless component.response

      component.response
    rescue NotFoundError
      raise if Env.development?

      [404, { "content-type" => "text/html" }, File.open("public/404.html")]
    rescue StandardError
      raise if Env.development?

      [500, { "content-type" => "text/html" }, File.open("public/500.html")]
    end

    private

    def find_route(path_info)
      params = nil || { "" => nil, "_" => "" } # use value as a type for steep?
      routes = YesRoutes.routes || []
      _, klass = routes.find do |route_path,|
        path_regex = Regexp.new("^#{route_path.gsub(/:(\w+)/, '(?<\1>[a-zA-Z0-9_\-=]+)')}$")
        params = path_info.match(path_regex)&.named_captures
      end

      [klass, params]
    end
  end
end
