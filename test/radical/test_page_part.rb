require File.dirname(__FILE__) + "/../helper"

class TestPagePart < Test::Unit::TestCase
  def test_includes_happymapper
    assert Radical::PagePart.included_modules.include?(HappyMapper)
  end

  def test_elements
    assert_equal %w{id name content}, Radical::PagePart.elements.collect(&:name)
  end

  def test_tag_name
    assert_equal 'part', Radical::PagePart.tag_name
  end
end
