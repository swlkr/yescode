class YesController
  class << self
    attr_accessor :before_actions

    def before_action(*symbols)
      @before_actions = symbols
    end

    def inherited(subclass)
      subclass.before_actions = @before_actions
      super
    end
  end

  def initialize(env)
    @env = env
  end

  def flash
    @flash ||= @env['rack.session']['__FLASH__']
  end

  def session
    @session ||= @env['rack.session']
  end

  def response(status, body = nil, headers = { "content-type" => "text/html; charset=utf-8" })
    [status, headers, [body].compact]
  end

  def ok(body = nil, headers = { "content-type" => "text/html; charset=utf-8" })
    response(200, body, headers)
  end

  def xml(body = nil)
    ok body, { "content-type" => "text/xml; charset=utf-8" }
  end

  def json(body = nil)
    ok body, { "content-type" => "application/json; charset=utf-8" }
  end

  def redirect(controller_or_url, method_name = nil, params = {})
    location = case controller_or_url
               when String
                 controller_or_url
               when Symbol
                 raise StandardError, "Unsupported type as first argument to redirect" if method_name.nil?

                 path(controller_or_url, method_name, params)
               end

    response(302, nil, { "Location" => location })
  end

  def params
    @env["params"]
  end

  def csrf_value
    YesCsrf.token(@env)
  end

  def csrf_name
    YesCsrf.field
  end

  def not_found
    [404, { "content-type" => "text/plain" }, ["not found"]]
  end

  def not_found!
    raise StandardError
  end

  def server_error
    [500, { "content-type" => "text/plain" }, ["internal server error"]]
  end

  def server_error!
    raise StandardError
  end

  def path(class_name, method_name, params = {})
    YesRoutes.path(class_name, method_name, params)
  end

  def ajax
    @env.key?("HTTP_YES_AJAX")
  end

  def render(view, layout: true)
    view.csrf_name = csrf_name
    view.csrf_value = csrf_value
    view.session = session
    view.ajax = ajax
    content = view.render(view.class.superclass.new.template) if layout

    ok content
  end
end
