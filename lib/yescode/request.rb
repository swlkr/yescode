# frozen_string_literal: true

require "rack"

module Yescode
  class Request < Hash
    attr_accessor :env

    def initialize(env)
      @env = env || {}
    end

    def []=(key, value)
      @env[key] = value
    end

    def [](key)
      @env[key]
    end

    def yes_ajax?
      @env.key?("HTTP_YES_AJAX")
    end

    def path_info
      @env[Rack::PATH_INFO]
    end

    def request_method
      @env[Rack::REQUEST_METHOD]
    end

    def rack_request_form_hash
      @env[Rack::RACK_REQUEST_FORM_HASH] || {}
    end

    def self.with(request_method, path_info)
      Request.new(
        {
          Rack::REQUEST_METHOD => request_method,
          Rack::PATH_INFO => path_info
        }
      )
    end
  end
end
