# frozen_string_literal: true

require "minitest/autorun"
require "yescode/router"

module Yescode
  class RouterTest < Minitest::Test
    def setup
      ENV["RACK_ENV"] = "test"
    end

    def test_raises_route_not_found_when_no_routes
      assert_raises RouteNotFound do
        request = Request.with("GET", "/")
        routes = {}
        Router.new(routes).call(request.env)
      end
    end

    def test_raises_route_missing_when_class_not_defined
      assert_raises RouteMissing do
        request = Request.with("GET", "/")
        routes = {
          "GET" => [
            Route.new("GET", "/", :Home, :index)
          ]
        }
        Router.new(routes).call(request.env)
      end
    end
  end
end
