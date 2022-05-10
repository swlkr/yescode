# frozen_string_literal: true

module Yescode
  class LogfmtFormatter < ::Logger::Formatter
    def call(severity, datetime, progname, msg)
      timestamp = datetime.strftime('%Y-%m-%d %H:%M:%S.%L')

      parts = {
        level: severity.downcase,
        in: progname
      }

      parts.merge!(msg)

      output = "[#{timestamp}] #{parts.reject { |_, v| v.nil? }.map { |k, v| "#{k}=#{v}" }.join(' ')}\n"

      if severity.downcase == "debug"
        blue(output)
      else
        output
      end
    end

    private

    def blue(str)
      "\e[34m#{str}\e[0m"
    end
  end
end
