require File.dirname(__FILE__) + "/../../helper"

class TestBase < Test::Unit::TestCase
  def setup
    @data_dir = File.expand_path(File.dirname(__FILE__) + "/../../data")
    @symlink_dir = "#{@data_dir}/links"
    FileUtils.rm_rf(Dir["#{@data_dir}/*"])

    @child = Class.new
    @child.send(:include, Radical::Models::Base)
    @child.element :id, Integer
    @child.element :name, String
    @child.element :content, String

    @klass = Class.new
    @klass.send(:include, Radical::Models::Base)
    @klass.element :id, Integer
    @klass.element :title, String
    @klass.has_many :parts, @child
  end

  def new_item
    item = @klass.new
    item.id = 1
    item.title = "Huge"
    sub_item_1 = @child.new
    sub_item_1.id = 1
    sub_item_1.name = 'Medium'
    sub_item_1.content = 'Blargh'
    sub_item_2 = @child.new
    sub_item_2.id = 2
    sub_item_2.name = 'Small'
    sub_item_2.content = 'Avast'
    item.parts = [ sub_item_1, sub_item_2 ]
    item
  end

  def test_includes_happymapper
    assert @klass.included_modules.include?(HappyMapper)
  end

  def test_to_files
    item = new_item
    files = [
      "1/parts/1/content.html", "1/parts/1/attribs.yml",
      "1/parts/2/content.html", "1/parts/2/attribs.yml",
      "1/attribs.yml",
    ].collect { |f| "#{@data_dir}/#{f}" }
    assert_equal files, item.to_files(@data_dir)

    # medium part
    attribs = "#{@data_dir}/1/parts/1/attribs.yml"
    assert File.exist?(attribs)
    assert_equal({'name' => 'Medium'}, YAML.load_file(attribs))

    content = "#{@data_dir}/1/parts/1/content.html"
    assert File.exist?(content)
    assert_equal "Blargh", open(content).read

    # small part
    attribs = "#{@data_dir}/1/parts/2/attribs.yml"
    assert File.exist?(attribs)
    assert_equal({'name' => 'Small'}, YAML.load_file(attribs))

    content = "#{@data_dir}/1/parts/2/content.html"
    assert File.exist?(content)
    assert_equal "Avast", open(content).read

    # attribs
    attribs = "#{@data_dir}/1/attribs.yml"
    assert File.exist?(attribs)
    assert_equal({'title' => 'Huge'}, YAML.load_file(attribs))
  end

  def test_to_files_with_symlinks
    item = new_item
    item.to_files(@data_dir, :symlinks => true)

    files = [
      "Huge/parts/Medium/content.html", "Huge/parts/Medium/attribs.yml",
      "Huge/parts/Small/content.html", "Huge/parts/Small/attribs.yml",
      "Huge/attribs.yml",
    ].each do |f|
      assert File.exist?("#{@data_dir}/#{f}")
    end

    ## medium part
    #attribs = "#{@data_dir}/1/parts/1/attribs.yml"
    #assert File.exist?(attribs)
    #assert_equal({'name' => 'Medium'}, YAML.load_file(attribs))

    #content = "#{@data_dir}/1/parts/1/content.html"
    #assert File.exist?(content)
    #assert_equal "Blargh", open(content).read

    ## small part
    #attribs = "#{@data_dir}/1/parts/2/attribs.yml"
    #assert File.exist?(attribs)
    #assert_equal({'name' => 'Small'}, YAML.load_file(attribs))

    #content = "#{@data_dir}/1/parts/2/content.html"
    #assert File.exist?(content)
    #assert_equal "Avast", open(content).read

    ## attribs
    #attribs = "#{@data_dir}/1/attribs.yml"
    #assert File.exist?(attribs)
    #assert_equal({'title' => 'Huge'}, YAML.load_file(attribs))
  end

  def test_from_files
    orig = new_item
    orig.parts[0].id = 11
    orig.parts[1].id = 12
    orig.to_files(@data_dir)

    item = @klass.from_files(@data_dir, orig.id)
    assert_equal orig.id, item.id
    assert_equal orig.title, item.title
    orig.parts.length.times do |i|
      assert_equal orig.parts[i].id, item.parts[i].id
      assert_equal orig.parts[i].name, item.parts[i].name
      assert_equal orig.parts[i].content, item.parts[i].content
    end
  end

  def test_to_params
    item = new_item
    expected = {
      'id' => '1', 'title' => 'Huge',
      'parts_attributes' => {
        '1' => { 'id' => '1', 'name' => 'Medium', 'content' => 'Blargh' },
        '2' => { 'id' => '2', 'name' => 'Small',  'content' => 'Avast'  },
      }
    }
    assert_equal expected, item.to_params
  end

  def test_to_hash
    item = new_item
    expected = {
      'id' => 1, 'title' => 'Huge',
      'parts' => [
        { 'id' => 1, 'name' => 'Medium', 'content' => 'Blargh' },
        { 'id' => 2, 'name' => 'Small',  'content' => 'Avast'  },
      ]
    }
    assert_equal expected, item.to_hash
  end
end
