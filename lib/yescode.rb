# frozen_string_literal: true

require "digest"
require "logger"
require "net/smtp"
require "mail"
require "rack"
require "stringio"
require "sqlite3"

require_relative "./yescode/version"
require_relative "./yescode/emote"
require_relative "./yescode/strings"
require_relative "./yescode/env"
require_relative "./yescode/logfmt_formatter"
require_relative "./yescode/router"
require_relative "./yescode/database"
require_relative "./yescode/queries"
require_relative "./yescode/assets"
require_relative "./yescode/asset_compiler"
require_relative "./yescode/generator"

require_relative "./yes_csrf"
require_relative "./yes_static"
require_relative "./yes_logger"
require_relative "./yes_rack_logger"
require_relative "./yes_routes"
require_relative "./yes_component"
require_relative "./yes_record"
require_relative "./yes_mail"
require_relative "./yes_app"

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
