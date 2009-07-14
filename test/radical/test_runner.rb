require File.dirname(__FILE__) + "/../helper"

class TestRunner < Test::Unit::TestCase
  def start_runner
    argv = ["-c",
      File.expand_path(File.dirname(__FILE__) + "/../fixtures/config.yml")
    ]
    Radical::Runner.new(argv)
  end

  def test_reading_config_from_options
    start_runner
    assert_equal "http://example.com:3000/admin", Radical::Fetcher.base_uri
    assert_equal({ :username => 'admin', :password => 'omghuge' },
      Radical::Fetcher.default_options[:basic_auth])
  end

  def test_creating
  end
end
