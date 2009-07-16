require File.dirname(__FILE__) + "/../../helper"

class TestSnippet < Test::Unit::TestCase
  def test_includes_base
    assert Radical::Models::Snippet.included_modules.include?(Radical::Models::Base)
  end

  def test_elements
    assert_equal %w{id name content}, Radical::Models::Snippet.elements.collect(&:name)
  end
end
