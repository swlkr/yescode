# frozen_string_literal: true

module Yescode
  class Assets
    class << self
      attr_accessor :css, :js

      def compile
        @css = AssetCompiler.compile(@css, "css") unless @css&.empty?
        @js = AssetCompiler.compile(@js, "js") unless @js&.empty?
      end
    end
  end
end
