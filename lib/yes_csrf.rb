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

    if skip?(env) || valid?(env)
      @app.call(env)
    else
      raise InvalidCsrfToken if @raise_if_invalid

      [403, {}, []]
    end
  end

  private

  def skip?(env)
    env[Rack::REQUEST_METHOD] == "GET"
  end

  def valid?(env)
    token = self.class.token(env)

    Rack::Utils.secure_compare(env["params"][FIELD].to_s, token) ||
      Rack::Utils.secure_compare(env["X_CSRF_TOKEN"].to_s, token)
  end
end
