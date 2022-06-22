require "fileutils"

module Yescode
  module Generators
    class Migration
      def initialize(name)
        @name = name
      end

      def call
        FileUtils.mkdir_p(dir)
        filename = File.join(dir, "#{Time.now.to_i}_#{@name}.sql")
        File.write(filename, "-- name: up\n\n-- name: down")
      end

      def dir
        File.join(".", "db", "migrations")
      end
    end
  end
end
