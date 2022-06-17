require "yescode"

# require_all is part of yescode
# it's supposed to be a simpler
# alternative to zeitwerk
require_all %w[
  ./app/components/layout
  ./app/components/*
]

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
