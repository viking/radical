require File.dirname(__FILE__) + "/../../helper"

class TestPage < Test::Unit::TestCase
  def setup
    @data_dir = File.expand_path(File.dirname(__FILE__) + "/../../data/pages")
    if File.exist?(@data_dir)
      FileUtils.rm_rf(Dir["#{@data_dir}/*"])
    else
      FileUtils.mkdir(@data_dir)
    end
  end

  def test_includes_base
    assert Radical::Models::Page.included_modules.include?(Radical::Models::Base)
  end

  def test_elements
    assert_equal %w{id title parts}, Radical::Models::Page.elements.collect(&:name)
  end
end
