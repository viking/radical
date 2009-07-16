require File.dirname(__FILE__) + "/../../helper"

class TestLayout < Test::Unit::TestCase
  def setup
    @data_dir = File.expand_path(File.dirname(__FILE__) + "/../../data/layouts")
    if File.exist?(@data_dir)
      FileUtils.rm_rf(Dir["#{@data_dir}/*"])
    else
      FileUtils.mkdir(@data_dir)
    end
  end

  def test_includes_base
    assert Radical::Models::Layout.included_modules.include?(Radical::Models::Base)
  end

  def test_elements
    assert_equal %w{id name content}, Radical::Models::Layout.elements.collect(&:name)
  end
end
