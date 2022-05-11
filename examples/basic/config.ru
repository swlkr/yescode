require "yescode"

class HomeIndex < YesView
  view "home_index.emote"
end

class Home < YesController
  def index
    HomeIndex.new
  end
end

class Routes < YesRoutes
  get "/", :Home, :index
end

class App < YesApp
  logger YesLogger.new($stdout)

  use YesStatic, root: "public" if development?
  use YesRackLogger
  use Rack::Runtime
  use Rack::ETag
  use Rack::Head
  use Rack::ContentLength
  use Rack::ContentType

  routes :Routes
end

run App
