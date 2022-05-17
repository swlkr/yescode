require "minitest/autorun"

module Yescode
  class TestStrings < Minitest::Test
    include Strings

    def test_snake_case_from_pascal
      assert_equal "hello_world", snake_case("HelloWorld")
    end

    def test_snake_case_from_camel
      assert_equal "hello_world", snake_case("helloWorld")
    end

    def test_camel_case_from_snake
      assert_equal "helloWorld", camel_case("hello_world")
    end

    def test_pascal_case_from_snake
      assert_equal "HelloWorld", pascal_case("hello_world")
    end
  end
end
