# frozen_string_literal: true

class YesRackLogger
  class << self
    attr_accessor :logger
  end

  def initialize(app)
    @app = app
    @logger = self.class.logger
  end

  def call(env)
    log_request(env)

    start_allocations = GC.stat[:total_allocated_objects]
    response = @app.call(env)
    allocations = GC.stat[:total_allocated_objects] - start_allocations

    log_response(env, response, allocations)

    response
  end

  private

  def common_parts(env)
    {
      method: env[Rack::REQUEST_METHOD],
      path: env[Rack::PATH_INFO],
      remote_addr: env["HTTP_X_FORWARDED_FOR"] || env["REMOTE_ADDR"],
      protocol: env[Rack::SERVER_PROTOCOL],
      content_type: env["CONTENT_TYPE"]
    }
  end

  def log_request(env)
    @logger&.info(
      msg: "Request started",
      **common_parts(env)
    )
  end

  def log_response(env, response, allocations)
    status, headers = response

    duration = headers["X-Runtime"]
    content_length = headers[Rack::CONTENT_LENGTH]

    @logger&.info(
      msg: "Response finished",
      **common_parts(env),
      content_length: content_length,
      status: status,
      duration: duration,
      allocations: allocations
    )
  end
end
