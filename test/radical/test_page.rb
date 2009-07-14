require File.dirname(__FILE__) + "/../helper"

class TestPage < Test::Unit::TestCase
  def test_includes_happymapper
    assert Radical::Page.included_modules.include?(HappyMapper)
  end

  def test_elements
    assert_equal %w{id title parts}, Radical::Page.elements.collect(&:name)
  end
end
