module Yescode
  module RequestCache
    class Middleware
      def initialize(app)
        @app = app
      end

      def call(env)
        RequestCache.begin!

        status, headers, body = @app.call(env)

        body = Rack::BodyProxy.new(body) do
          RequestCache.end!
          RequestCache.clear!
        end

        returned = true

        [status, headers, body]
      ensure
        unless returned
          RequestCache.end!
          RequestCache.clear!
        end
      end
    end
  end
end
