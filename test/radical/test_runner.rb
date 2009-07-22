require File.dirname(__FILE__) + "/../helper"

class TestRunner < Test::Unit::TestCase
  def setup
    @pages = Radical::Models::Page.parse(file_fixture('pages.xml'))
    Radical::Fetcher.expects(:get).with('page', :all).returns(@pages)
    @layouts = Radical::Models::Layout.parse(file_fixture('layouts.xml'))
    Radical::Fetcher.expects(:get).with('layout', :all).returns(@layouts)
    @snippets = Radical::Models::Snippet.parse(file_fixture('snippets.xml'))
    Radical::Fetcher.expects(:get).with('snippet', :all).returns(@snippets)

    @data_dir = File.expand_path(File.dirname(__FILE__) + "/../data")
    FileUtils.rm_rf(Dir["#{@data_dir}/*"])

    test_path = File.expand_path(File.dirname(__FILE__) + "/..")
    @argv = %W{-c #{test_path}/fixtures/config.yml -d #{test_path}/data -x}
  end

  def start_runner
    Radical::Runner.new(@argv)
  end

  def test_reading_config_from_options
    start_runner
    assert_equal "http://example.com:3000/admin", Radical::Fetcher.base_uri
    assert_equal({ :username => 'admin', :password => 'omghuge' },
      Radical::Fetcher.default_options[:basic_auth])
  end

  def test_command_line_args_override
    @argv += %w{-u foo -p bar -b http://example.com:3000/huge}
    start_runner
    assert_equal "http://example.com:3000/huge", Radical::Fetcher.base_uri
    assert_equal({ :username => 'foo', :password => 'bar' },
      Radical::Fetcher.default_options[:basic_auth])
  end

  def test_creating_files
    @pages.each do |page|
      page.expects(:to_files).with(File.expand_path("test/data/pages"), :symlinks => true).returns([])
    end
    @layouts.each do |layout|
      layout.expects(:to_files).with(File.expand_path("test/data/layouts"), :symlinks => true).returns([])
    end
    @snippets.each do |snippet|
      snippet.expects(:to_files).with(File.expand_path("test/data/snippets"), :symlinks => true).returns([])
    end
    start_runner
  end

  def test_updating_page
    Radical::Fetcher.expects(:put)

    runner = start_runner
    body = "#{@data_dir}/pages/1/parts/1/content.html"
    File.open(body, 'w') { |f| f.print "Huge" }
    File.utime(Time.now + 10, Time.now + 10, body)
    runner.check
  end

  def test_updating_layout
    Radical::Fetcher.expects(:put)

    runner = start_runner
    body = "#{@data_dir}/layouts/1/content.html"
    File.open(body, 'w') { |f| f.print "Huge" }
    File.utime(Time.now + 10, Time.now + 10, body)
    runner.check
  end

  def test_updating_snippet
    Radical::Fetcher.expects(:put)

    runner = start_runner
    body = "#{@data_dir}/snippets/1/content.html"
    File.open(body, 'w') { |f| f.print "Huge" }
    File.utime(Time.now + 10, Time.now + 10, body)
    runner.check
  end
end
