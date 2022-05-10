# frozen_string_literal: true

module Yescode
  class Assets
    def initialize
      @assets_path = File.join(".", "app")
      @assets = Hash.new { |hash, key| hash[key] = [] }
    end

    def css(filenames = [])
      @assets["css"] = filenames
    end

    def js(filenames = [])
      @assets["js"] = filenames
    end

    def compile_assets
      css = AssetCompiler.compile(@assets, "css") unless @assets["css"].empty?
      js = AssetCompiler.compile(@assets, "js") unless @assets["js"].empty?

      @assets["css"] = [css]
      @assets["js"] = [js]
    end

    def to_h
      @assets
    end
  end
end
