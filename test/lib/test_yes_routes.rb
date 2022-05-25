require "minitest/autorun"

class TestYesRoutes < Minitest::Test
  def setup
    YesRoutes.routes = Hash.new { |hash, key| hash[key] = [] }
  end

  def test_action_adds_action_routes
    expected = {
      "GET" => [
        ["/signup", :Signups, :new]
      ],
      "POST" => [
        ["/signup", :Signups, :create]
      ]
    }
    YesRoutes.action("/signup", :Signups)

    assert_equal expected, YesRoutes.routes
  end

  def test_actions_adds_actions_routes
    expected = {
      "GET" => [
        ["/profile", :Profile, :show],
        ["/profile/new", :Profile, :new],
        ["/profile/edit", :Profile, :edit]
      ],
      "POST" => [
        ["/profile/new", :Profile, :create],
        ["/profile/edit", :Profile, :update],
        ["/profile/delete", :Profile, :delete]
      ]
    }
    YesRoutes.actions("/profile", :Profile)

    assert_equal expected, YesRoutes.routes
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

  def test_resources_routes_with_valid_input
    expected = {
      "GET" => [
        ["/todos", :Todos, :index],
        ["/todos/new", :Todos, :new],
        ["/todos/:todo_id", :Todos, :show],
        ["/todos/:todo_id/edit", :Todos, :edit]
      ],
      "POST" => [
        ["/todos/new", :Todos, :create],
        ["/todos/:todo_id/edit", :Todos, :update],
        ["/todos/:todo_id/delete", :Todos, :delete]
      ]
    }
    YesRoutes.resources("/todos/:todo_id", :Todos)

    assert_equal expected, YesRoutes.routes
  end

  def test_resources_routes_with_invalid_input
    assert_raises(StandardError, "Needs at least two url segments") { YesRoutes.resources("", :Todos) }
  end

  def test_resources_routes_without_param_as_last_segment
    assert_raises(StandardError, "The last url segment needs to be a param") { YesRoutes.resources("/todos/hello", :Todos) }
  end
end
