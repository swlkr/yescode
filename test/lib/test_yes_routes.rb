require "minitest/autorun"
require "./lib/yes_routes"
require "./lib/yescode/refinements"

class TestYesRoutes < Minitest::Test
  def setup
    ENV["RACK_ENV"] = "test"
    YesRoutes.routes = Hash.new { |hash, key| hash[key] = [] }
  end

  def test_resource_adds_resource_routes
    expected = {
      "GET" => [
        ["/todos", :Todos, :index],
        ["/todos/new", :Todos, :new],
        ["/todos/:id", :Todos, :show],
        ["/todos/:id/edit", :Todos, :edit]
      ],
      "POST" => [
        ["/todos/new", :Todos, :create],
        ["/todos/:id/edit", :Todos, :update],
        ["/todos/:id/delete", :Todos, :delete]
      ]
    }
    YesRoutes.resource("/todos", :Todos)

    assert_equal expected, YesRoutes.routes
  end

  def test_nested_resource_routes
    expected = {
      "GET" => [
        ["/todos/:todo_id/comments", :Comments, :index],
        ["/todos/:todo_id/comments/new", :Comments, :new],
        ["/todos/:todo_id/comments/:id", :Comments, :show],
        ["/todos/:todo_id/comments/:id/edit", :Comments, :edit]
      ],
      "POST" => [
        ["/todos/:todo_id/comments/new", :Comments, :create],
        ["/todos/:todo_id/comments/:id/edit", :Comments, :update],
        ["/todos/:todo_id/comments/:id/delete", :Comments, :delete]
      ]
    }
    YesRoutes.resource("/todos/:todo_id/comments", :Comments)

    assert_equal expected, YesRoutes.routes
  end
end
