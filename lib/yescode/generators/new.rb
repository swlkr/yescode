# frozen_string_literal: true

require "fileutils"
require "securerandom"
require "erb"

module Yescode
  module Generators
    class New
      HELP_MESSAGE = <<~TXT
        Usage: yescode new [name]

        Create a new yescode application

        Example:
          yescode new todos

        This will generate a new yescode application in ./todos
      TXT

      def self.secret
        SecureRandom.hex(32)
      end

      def self.call(dir)
        if dir.nil?
          puts HELP_MESSAGE
          return
        end

        # create app folder in current folder
        FileUtils.mkdir_p(File.join(".", dir))

        # create other foldres
        {
          "public" => %w[css js],
          "db" => %w[migrations],
          "app" => %w[models components emails jobs modules]
        }.each do |k, v|
          v.each do |folder|
            FileUtils.mkdir_p(File.join(".", dir, k, folder))
          end
        end

        Dir.glob(File.join(__dir__, "new", "**", "*.erb"), File::FNM_DOTMATCH).each do |file|
          erb = File.read(file)
          template = ERB.new(erb)
          basename = File.basename(file).gsub(/.erb$/, "")
          parts = File.dirname(file).split(File::SEPARATOR)
          index = parts.index("new") + 1
          pathname = parts[index..]
          output = File.join(".", dir, *pathname, basename)

          File.write(output, template.result(binding))
          File.chmod(0x0777, output) if basename == "restart-dev-server.sh"
        end
      end
    end
  end
end
