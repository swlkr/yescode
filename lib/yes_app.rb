# frozen_string_literal: true

class YesApp
  class << self
    attr_accessor :middleware

    def use(middleware, *args)
      @middleware ||= []
      @middleware << [middleware, args]
    end

    def app
      @app || build_rack_app
    end

    def build_rack_app
      builder = Rack::Builder.new

      middleware&.each do |m, args|
        m.logger = @logger if m.respond_to?(:logger=)
        builder.use(m, *args)
      end

      builder.use Yescode::RequestCache::Middleware
      builder.run Yescode::Router.new

      @app = builder.to_app
    end

    def freeze
      build_rack_app
      @app.freeze
      @middleware.freeze

      super
    end

    def call(env)
      app.call(env)
    end

    def logger(logger_class, params: true, database: true)
      @logger = logger_class
      Yescode::Database.logger = logger_class if database
      Yescode::Router.logger = logger_class if params
    end

    def css(filenames)
      Yescode::Assets.css ||= []
      filenames.each do |filename|
        Yescode::Assets.css << filename
      end
    end

    def js(filenames)
      Yescode::Assets.js ||= []
      filenames.each do |filename|
        Yescode::Assets.js << filename
      end
    end

    def bundle_static_files
      Yescode::Assets.compile
    end

    def migrations(dir)
      @migrations ||= Dir[dir]
    end

    def migrate
      Yescode::Database.logger = YesLogger.new($stdout)
      Yescode::Database.migrate(@migrations || Dir["./db/migrations/*.sql"])
    end

    def rollback(step)
      Yescode::Database.logger = YesLogger.new($stdout)
      Yescode::Database.rollback_schema(@migrations || Dir["./db/migrations/*.sql"], step:)
    end

    def development?
      Yescode::Env.development?
    end

    def test?
      Yescode::Env.test?
    end

    def production?
      Yescode::Env.production?
    end

    def default_session_cookie(options = {})
      {
        path: "/",
        expire_after: 2_592_000,
        secret: ENV["SECRET"],
        http_only: true,
        same_site: :strict,
        secure: production?
      }.merge(options)
    end
  end
end
