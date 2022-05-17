# frozen_string_literal: true

require "yescode/errors"
require "yescode/env"
require "yescode/route"
require "yescode/request"

module Yescode
  class Router
    class << self
      attr_accessor :logger, :assets
    end

    def initialize(routes)
      @routes = routes
    end

    def call(env)
      params = {}
      request = Request.new(env)
      route = @routes[request.request_method]&.find do |r|
        path = Regexp.new("^#{r.path.gsub(/:(\w+)/, '(?<\1>[a-zA-Z0-9_\-=]+)')}$")
        params = request.path_info.match(path)&.named_captures
      end

      raise RouteNotFound unless route

      params.merge!(request.rack_request_form_hash).transform_keys!(&:to_sym)
      request["params"] = params

      controller = route.controller!(request)

      self.class.logger&.info(
        msg: "Request dispatched",
        route: "#{route.class_name}##{route.method_name}",
        params: params.except(:_csrf)
      )

      controller.class.before_actions&.each do |before_action|
        controller.send(before_action)
      end
      response = controller.public_send(route.method_name)

      raise NotFoundError if response.nil?

      case response
      when YesView
        response.csrf_name = controller.csrf_name
        response.csrf_value = controller.csrf_value
        response.assets = self.class.assets&.to_h || {}
        response.session = controller.session
        response.ajax = request.yes_ajax?
        layout = controller.class.layout
        content = response.render(response.template)
        content = response.render(layout.template, content:) if layout && response.class < layout.class
        controller.ok content
      else
        response
      end
    rescue NotFoundError, RouteNotFound
      raise if Env.development? || Env.test?

      [404, { "content-type" => "text/html" }, File.open("public/404.html")]
    rescue StandardError
      raise if Env.development? || Env.test?

      [500, { "content-type" => "text/html" }, File.open("public/500.html")]
    end
  end
end
