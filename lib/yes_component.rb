# frozen_string_literal: true

class YesComponent
  extend Yescode::Strings

  class << self
    attr_accessor :before_actions, :logger

    def before_action(*symbols)
      @before_actions = symbols
    end

    def inherited(subclass)
      subclass.before_actions = @before_actions
      super
    end

    def template_name
      @html || "#{filename}.html.erb"
    end

    def template_path
      File.join(".", "app", "components", template_name)
    end

    def template_file
      @template_file ||= File.read(template_path)
    end

    def compiled_template
      @compiled_template ||= Erubi::Engine.new(template_file, escape: true, freeze: true).src
    rescue Errno::ENOENT => _e
      return if template_name == "yes_component.html.erb"

      YesComponent.logger&.info(msg: "Missing template", name: template_name)
    end

    def path(params = {})
      YesRoutes.path(self, params)
    end

    def html(name)
      @html = name
    end
  end

  compiled_template

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
    YesComponent.logger&.info(msg: "Rendering", component: self.class.to_s)

    body ||= instance_eval(self.class.compiled_template)
    if layout && !yes_frame?
      @body = body
      body = instance_eval(self.class.superclass.compiled_template)
    end

    ok(body, { "content-type" => "text/html; charset=utf-8" })
  end

  def csv(body = nil)
    ok(body, { "content-type" => "text/csv; charset=utf-8" })
  end

  def redirect(location)
    respond(302, nil, { "Location" => location })
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

  def yes_frame?
    @env.key?("HTTP_YES_FRAME")
  end

  def css
    Yescode::Assets.css&.map { |filename| "/css/#{filename}" }
  end

  def js
    Yescode::Assets.js&.map { |filename| "/js/#{filename}" }
  end

  def render(klass)
    component = klass.new(@env)
    component.get
    component.html(nil, layout: false) unless component.body

    component.body
  end

  def view(klass)
    component = klass.new(@env)
    component.get
    component.html(nil, layout: true) unless component.body

    component.body
  end

  def call
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

  def tag
    @tag ||= YesTag.new
  end

  def get; end

  def post; end

  private

  def request_method
    @env[Rack::REQUEST_METHOD]
  end
end
