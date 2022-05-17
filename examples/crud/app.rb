require "yescode"

# require_all is part of yescode
# it's supposed to be a simpler
# alternative to zeitwerk
require_all %w[
  ./app/models/*
  ./app/views/layout
  ./app/views/*
  ./app/controllers/*
  ./app/routes
]

class App < YesApp
  logger YesLogger.new($stdout)

  use YesStatic, root: "public" if development?
  use YesRackLogger
  use Rack::ShowExceptions if development?
  use Rack::Runtime
  use Rack::ETag
  use Rack::Head
  use Rack::ContentLength
  use Rack::ContentType
  use Rack::Session::Cookie, default_session_cookie
  use Rack::Csrf, raise: development?

  migrations "db/migrations/*.sql"

  routes :Routes

  if production?
    migrate
    bundle_static_files
  end
end
