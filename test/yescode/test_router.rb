require "minitest/autorun"

module Yescode
  class TestRouter < Minitest::Test
    def setup
      @router = Router.new
    end

    def test_find_route_with_no_params
      YesRoutes.routes = {
        "GET" => [["/", :Home, :index]]
      }

      actual = @router.send(:find_route, "GET", "/")
      expected = [["/", :Home, :index], {}]

      assert_equal expected, actual
    end

    def test_find_route_with_simple_params
      YesRoutes.routes = {
        "GET" => [["/todos/:todo_id/edit", :Todos, :edit]]
      }

      actual = @router.send(:find_route, "GET", "/todos/123/edit")
      expected = [["/todos/:todo_id/edit", :Todos, :edit], { "todo_id" => "123" }]

      assert_equal expected, actual
    end

    def test_find_route_with_less_simple_params
      YesRoutes.routes = {
        "GET" => [["/@:username", :Profile, :show]]
      }

      actual = @router.send(:find_route, "GET", "/@swlkr")
      expected = [["/@:username", :Profile, :show], { "username" => "swlkr" }]

      assert_equal expected, actual
    end

    def test_find_route_with_even_less_simple_params
      YesRoutes.routes = {
        "GET" => [["/filter-:filter1-:filter2-:filter3", :A, :b]]
      }

      actual = @router.send(:find_route, "GET", "/filter-hello-there-world")
      expected = [
        ["/filter-:filter1-:filter2-:filter3", :A, :b],
        { "filter1" => "hello", "filter2" => "there", "filter3" => "world" }
      ]

      assert_equal expected, actual
    end
  end
end
