# frozen_string_literal: true

module Yescode
  class Env
    class << self
      def development?
        ENV["RACK_ENV"] == "development"
      end

      def test?
        ENV["RACK_ENV"] == "test"
      end

      def production?
        ENV["RACK_ENV"] == "production"
      end
    end
  end

  def self.env
    Env
  end
end
