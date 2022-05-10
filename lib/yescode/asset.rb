# frozen_string_literal: true

module Yescode
  class Asset
    attr_reader :path

    def initialize(filename, path:)
      @filename = filename
      @path = path
    end

    def full_path
      File.join(path, @filename)
    end

    def content
      File.read(full_path)
    end

    def ext
      File.extname(@filename)
    end
  end
end
