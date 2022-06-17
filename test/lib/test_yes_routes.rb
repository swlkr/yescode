require "minitest/autorun"

class TestYesRoutes < Minitest::Test
  def setup
    YesRoutes.routes = []
  end

  def test_route_adds_routes
    expected = [["/signup", :Signups]]
    YesRoutes.route("/signup", :Signups)
    assert_equal expected, YesRoutes.routes
  end
end
