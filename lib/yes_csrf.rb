# frozen_string_literal: true

class YesCsrf
  class SessionUnavailable < StandardError; end
  class InvalidCsrfToken < StandardError; end

  FIELD = "_csrf"

  def self.token(env)
    env["rack.session"]["csrf.token"] ||= SecureRandom.urlsafe_base64(32)
  end

  def initialize(app, options = {})
    @app = app
    @raise_if_invalid = options[:raise] || false
  end

  def call(env)
    raise SessionUnavailable, "YesCsrf depends on session middleware" unless env["rack.session"]

    request = Rack::Request.new(env)

    if skip?(request) || valid?(request)
      @app.call(env)
    else
      raise InvalidCsrfToken if @raise_if_invalid

      [403, {}, []]
    end
  end

  private

  def skip?(request)
    request.request_method == "GET"
  end

  def valid?(request)
    token = self.class.token(request.env)

    Rack::Utils.secure_compare(request.params[FIELD].to_s, token) ||
      Rack::Utils.secure_compare(request["X_CSRF_TOKEN"].to_s, token)
  end
end
