# frozen_string_literal: true

require "digest"
require "logger"
require "net/smtp"
require "mail"
require "rack"
require "rack/csrf"
require "stringio"
require "sqlite3"

require "./lib/yescode/request_cache"
require "./lib/yescode/request_cache/middleware"
require "./lib/yescode/refinements"
require "./lib/yescode/emote"
require "./lib/yescode/strings"
require "./lib/yescode/env"
require "./lib/yescode/logfmt_formatter"
require "./lib/yescode/router"
require "./lib/yescode/database"
require "./lib/yescode/queries"
require "./lib/yescode/assets"
require "./lib/yescode/asset_compiler"

require "./lib/yes_static"
require "./lib/yes_logger"
require "./lib/yes_rack_logger"
require "./lib/yes_routes"
require "./lib/yes_controller"
require "./lib/yes_view"
require "./lib/yes_record"
require "./lib/yes_mail"
require "./lib/yes_app"

def require_all(paths)
  paths.each do |path|
    if path.end_with?("*")
      Dir[path].sort.each do |f|
        next unless f.end_with?("rb")

        require f
      end
    else
      require path
    end
  end
end
