require File.dirname(__FILE__) + "/../../helper"

class TestPage < Test::Unit::TestCase
  def setup
    @data_dir = File.expand_path(File.dirname(__FILE__) + "/../../data/pages")
    FileUtils.rm_rf(Dir["#{@data_dir}/*"])
  end

  def test_includes_happymapper
    assert Radical::Models::Page.included_modules.include?(HappyMapper)
  end

  def test_elements
    assert_equal %w{id title parts}, Radical::Models::Page.elements.collect(&:name)
  end

  def test_to_files
    page = Radical::Models::Page.parse(file_fixture('page.xml'))
    files = [
      "1/attribs.yml",
      "1/parts/1/attribs.yml", "1/parts/1/content.html",
      "1/parts/2/attribs.yml", "1/parts/2/content.html"
    ].collect { |f| "#{@data_dir}/#{f}" }
    assert_equal files, page.to_files(@data_dir)

    # part 1 (body)
    attribs = "#{@data_dir}/1/parts/1/attribs.yml"
    assert File.exist?(attribs)
    assert_equal({'name' => 'body'}, YAML.load_file(attribs))

    content = "#{@data_dir}/1/parts/1/content.html"
    assert File.exist?(content)
    assert_equal "Hello world!", open(content).read

    # part 2 (extended)
    attribs = "#{@data_dir}/1/parts/2/attribs.yml"
    assert File.exist?(attribs)
    assert_equal({'name' => 'extended'}, YAML.load_file(attribs))

    content = "#{@data_dir}/1/parts/2/content.html"
    assert File.exist?(content)
    assert_equal "", open(content).read

    # page
    attribs = "#{@data_dir}/1/attribs.yml"
    assert File.exist?(attribs)
    assert_equal({'title' => 'Home'}, YAML.load_file(attribs))
  end

  def test_from_files
    orig = Radical::Models::Page.parse(file_fixture('page.xml'))
    orig.to_files(@data_dir)

    page = Radical::Models::Page.from_files(@data_dir, orig.id)
    assert_equal orig.id, page.id
    assert_equal orig.title, page.title
    orig.parts.length.times do |i|
      assert_equal orig.parts[i].id, page.parts[i].id
      assert_equal orig.parts[i].name, page.parts[i].name
      assert_equal orig.parts[i].content, page.parts[i].content
    end
  end
end
