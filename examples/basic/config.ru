require "yescode"

class Home < YesComponent
  def get; end
end

class Routes < YesRoutes
  route "/", Home
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
end

run App
