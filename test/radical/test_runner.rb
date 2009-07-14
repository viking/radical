require File.dirname(__FILE__) + "/../helper"

class TestRunner < Test::Unit::TestCase
  def setup
    @pages = Radical::Models::Page.parse(file_fixture('pages.xml'))
    Radical::Fetcher.expects(:get_pages).returns(@pages)

    @data_dir = File.expand_path(File.dirname(__FILE__) + "/../data")
    FileUtils.rm_rf(Dir["#{@data_dir}/*"])
  end

  def start_runner
    argv = ["-c", File.expand_path(File.dirname(__FILE__) + "/../fixtures/config.yml")]
    Radical::Runner.new(argv)
  end

  def test_reading_config_from_options
    start_runner
    assert_equal "http://example.com:3000/admin", Radical::Fetcher.base_uri
    assert_equal({ :username => 'admin', :password => 'omghuge' },
      Radical::Fetcher.default_options[:basic_auth])
  end

  def test_creating_files
    @pages.each do |page|
      page.expects(:to_files).with(File.expand_path("test/data/pages")).returns([])
    end
    start_runner
  end

  def test_updating_page
    Radical::Fetcher.expects(:put_page)

    runner = start_runner
    body = "#{@data_dir}/pages/1/parts/1/content.html"
    File.open(body, 'w') { |f| f.print "Huge" }
    File.utime(Time.now + 10, Time.now + 10, body)
    runner.check
  end
end
