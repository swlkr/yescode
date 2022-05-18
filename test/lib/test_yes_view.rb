require "minitest/autorun"

class TestYesView < Minitest::Test
  class HomeIndex < YesView; end

  def test_template_name
    assert_equal "home_index.emote", HomeIndex.template_name
  end
end
