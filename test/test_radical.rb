require File.dirname(__FILE__) + "/helper"

class TestRadical < Test::Unit::TestCase
  def test_setup
    Radical.setup({
      'base_uri' => "http://localhost:3000/admin",
      'username' => "admin", 'password' => "radiant"
    })
    assert_equal "http://localhost:3000/admin", Radical::Fetcher.base_uri
    assert_equal({:username => "admin", :password => "radiant"},
      Radical::Fetcher.default_options[:basic_auth])
  end
end
