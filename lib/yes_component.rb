# frozen_string_literal: true

class YesComponent
  include Emote::Helpers
  extend Yescode::Strings

  class << self
    attr_accessor :before_actions

    def before_action(*symbols)
      @before_actions = symbols
    end

    def inherited(subclass)
      subclass.before_actions = @before_actions
      super
    end

    def template_name
      name = @template || "#{filename}.emote"
      File.join(".", "app", "components", name)
    end

    def template(name)
      @template = name
    end
  end

  attr_accessor :response, :body

  def initialize(env)
    @env = env
  end

  def flash
    @flash ||= @env['rack.session']['__FLASH__']
  end

  def session
    @session ||= @env['rack.session']
  end

  def respond(status, body = nil, headers = { "content-type" => "text/html; charset=utf-8" })
    @body = body
    @response = [status, headers, [body].compact]
  end

  def ok(body = nil, headers = { "content-type" => "text/html; charset=utf-8" })
    respond(200, body, headers)
  end

  def xml(body = nil)
    ok(body, { "content-type" => "text/xml; charset=utf-8" })
  end

  def json(body = nil)
    ok(body, { "content-type" => "application/json; charset=utf-8" })
  end

  def html(body = nil, layout: true)
    body ||= emote(self.class.template_name)
    body = emote(self.class.superclass.template_name, { component: body }) if layout && !yes_frame?

    ok(body, { "content-type" => "text/html; charset=utf-8" })
  end

  def render(klass)
    component = klass.new(@env)
    component.get
    component.html(nil, layout: false) unless component.body

    component.body
  end

  def redirect(component_or_url, params = {})
    case component_or_url
    when Class, Symbol
      respond(302, nil, { "Location" => path(component_or_url, params) })
    when String
      respond(302, nil, { "Location" => component_or_url })
    else
      raise(StandardError, "redirect has received invalid type in first argument")
    end
  end

  def params
    @params ||= @env["params"]
  end

  def csrf_value
    YesCsrf.token(@env)
  end

  def not_found!
    raise NotFoundError
  end

  def server_error!
    raise ServerError
  end

  def path(class_name, params = {})
    YesRoutes.path(class_name, params)
  end

  def yes_frame?
    @env.key?("HTTP_YES_FRAME")
  end

  def csrf_field
    "<input type=\"hidden\" name=\"#{YesCsrf::FIELD}\" value=\"#{csrf_value}\" />"
  end

  def form(params = {})
    params = { method: "post" }.merge(params)
    attr_string = params.map { |k, v| "#{k}=\"#{v}\"" }.join(" ")

    <<~HTML
      <form #{attr_string}>
        #{csrf_field}
    HTML
  end

  def _form
    "</form>"
  end

  def form_link(str, component_class, params = {})
    <<~HTML
      #{form(action: path(component_class, params))}
        <input type="submit" value="#{str}" />
      #{_form}
    HTML
  end

  def css
    Yescode::Assets.css&.map { |filename| "/css/#{filename}" }
  end

  def js
    Yescode::Assets.js&.map { |filename| "/js/#{filename}" }
  end

  def dispatch
    case request_method
    when "GET"
      get
    when "POST"
      post
    else
      raise StandardError, "Request methods #{request_method} not supported"
    end

    html unless response
  end

  private

  def request_method
    @env["REQUEST_METHOD"]
  end
end
