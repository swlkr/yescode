# frozen_string_literal: true

class YesApp
  class << self
    attr_accessor :middleware, :assets, :route_class
    attr_writer :routes

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

      Yescode::Router.assets = @assets
      builder.run Yescode::Router.new(@routes)

      @app = builder.to_app
    end

    def freeze
      build_rack_app
      @app.freeze
      @middleware.freeze
      @assets.freeze

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

    def css(arr)
      @assets ||= Yescode::Assets.new
      @assets.css(arr)
    end

    def js(arr)
      @assets ||= Yescode::Assets.new
      @assets.js(arr)
    end

    def bundle_static_files
      @assets ||= Yescode::Assets.new
      @assets.compile_assets
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

    def routes(class_name = :Routes)
      @route_class = Object.const_get(class_name)
      @routes ||= @route_class.routes
    end

    def paths
      @paths ||= @route_class.paths
    end

    def path(class_name, method_name, params = {})
      @route_class.path(class_name, method_name, params)
    end
  end
end
