# frozen_string_literal: true

require "digest"
require "logger"
require "net/smtp"
require "mail"
require "rack"
require "rack/csrf"
require "stringio"
require "sqlite3"

require "yescode/errors"
require "yescode/strings"
require "yescode/request_cache"
require "yescode/request_cache/middleware"
require "yescode/refinements"
require "yescode/emote"
require "yescode/env"
require "yescode/logfmt_formatter"
require "yescode/route"
require "yescode/resource"
require "yescode/router"
require "yescode/database"
require "yescode/queries"
require "yescode/assets"
require "yescode/asset_compiler"
require "yescode/generator"

require "yes_static"
require "yes_logger"
require "yes_rack_logger"
require "yes_routes"
require "yes_controller"
require "yes_view"
require "yes_record"
require "yes_mail"
require "yes_app"

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
