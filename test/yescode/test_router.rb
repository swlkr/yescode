require "minitest/autorun"

module Yescode
  class TestRouter < Minitest::Test
    def setup
      @router = Router.new
    end

    def test_find_route_with_no_params
      YesRoutes.routes = [["/", :Home, :index]]

      actual = @router.send(:find_route, "/")
      expected = [:Home, {}]

      assert_equal expected, actual
    end

    def test_find_route_with_simple_params
      YesRoutes.routes = [["/todos/:todo_id/edit", :Todos]]

      actual = @router.send(:find_route, "/todos/123/edit")
      expected = [:Todos, { "todo_id" => "123" }]

      assert_equal expected, actual
    end

    def test_find_route_with_less_simple_params
      YesRoutes.routes = [["/@:username", :Profile, :show]]

      actual = @router.send(:find_route, "/@swlkr")
      expected = [:Profile, { "username" => "swlkr" }]

      assert_equal expected, actual
    end

    def test_find_route_with_even_less_simple_params
      YesRoutes.routes = [["/filter-:filter1-:filter2-:filter3", :A, :b]]

      actual = @router.send(:find_route, "/filter-hello-there-world")
      expected = [
        :A,
        { "filter1" => "hello", "filter2" => "there", "filter3" => "world" }
      ]

      assert_equal expected, actual
    end
  end
end
