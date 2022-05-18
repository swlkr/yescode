require "minitest/autorun"

class TestYesRecord < Minitest::Test
  class Todo < YesRecord; end
  class TodoItem < YesRecord; end

  def test_table_name_with_one_part
    assert_equal "todo", Todo.table_name
  end

  def test_table_name_with_two_parts
    assert_equal "todo_item", TodoItem.table_name
  end
end
