require File.dirname(__FILE__) + "/../../helper"

class TestPagePart < Test::Unit::TestCase
  def test_includes_base
    assert Radical::Models::PagePart.included_modules.include?(Radical::Models::Base)
  end

  def test_elements
    assert_equal %w{id name content}, Radical::Models::PagePart.elements.collect(&:name)
  end

  def test_tag_name
    assert_equal 'part', Radical::Models::PagePart.tag_name
  end
end
