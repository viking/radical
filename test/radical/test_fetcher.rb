require File.dirname(__FILE__) + "/../helper"

class TestFetcher < Test::Unit::TestCase
  def test_includes_httparty
    assert Radical::Fetcher.included_modules.include?(HTTParty)
  end

  def test_plain_format
    assert_equal :plain, Radical::Fetcher.default_options[:format]
  end

  def test_get_pages
    stub_http_response_with("pages.xml")
    pages = Radical::Fetcher.get_pages
    assert_equal 2, pages.length
  end

  def test_get_page
    stub_http_response_with("page.xml")
    page = Radical::Fetcher.get_page(1)
    assert_equal 1, page.id
    assert_equal "Home", page.title
  end

  def test_put_page
    page = Radical::Page.parse(file_fixture('page.xml'))
    page.title = 'Huge'

    Radical::Fetcher.expects(:post).with("/pages/1.xml", {
      :query => { 'page' => { 'title' => 'Huge' }, '_method' => 'put' }
    })
    Radical::Fetcher.put_page(page)
  end
end
