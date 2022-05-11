class YesController
  class << self
    attr_accessor :before_actions
    attr_writer :layout

    def layout
      @layout || Object.const_get(:Layout).new
    rescue NameError => _e
      nil
    end

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

  def redirect(controller_or_url, method_name = nil, params = {})
    if method_name
      response 302, nil, { "Location" => path(controller_or_url, method_name, params) }
    else
      response 302, nil, { "Location" => controller_or_url }
    end
  end

  def params
    @env["params"]
  end

  def csrf_value
    Rack::Csrf.token(@env) if @env['rack.session']
  end

  def csrf_name
    Rack::Csrf.field
  end

  def not_found
    [404, {"content-type" => "text/plain"}, ["not found"]]
  end

  def not_found!
    raise NotFoundError
  end

  def server_error
    [500, {"content-type" => "text/plain"}, ["internal server error"]]
  end

  def server_error!
    raise ServerError
  end

  def path(*args)
    Object.const_get(:App).path(*args)
  end
end
