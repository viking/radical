require File.dirname(__FILE__) + "/../helper"

class TestFetcher < Test::Unit::TestCase
  def test_includes_httparty
    assert Radical::Fetcher.included_modules.include?(HTTParty)
  end

  def test_plain_format
    assert_equal :plain, Radical::Fetcher.default_options[:format]
  end

  def test_get_all_pages
    stub_http_response_with("pages.xml")
    pages = Radical::Fetcher.get(:page, :all)
    assert_equal 2, pages.length
    assert_kind_of Radical::Models::Page, pages[0]
  end

  def test_get_all_layouts
    stub_http_response_with("layouts.xml")
    layouts = Radical::Fetcher.get(:layout, :all)
    assert_equal 2, layouts.length
    assert_kind_of Radical::Models::Layout, layouts[0]
  end

  def test_get_all_snippets
    stub_http_response_with("snippets.xml")
    snippets = Radical::Fetcher.get(:snippet, :all)
    assert_equal 1, snippets.length
    assert_kind_of Radical::Models::Snippet, snippets[0]
  end

  def test_get_page
    stub_http_response_with("page.xml")
    page = Radical::Fetcher.get(:page, 1)
    assert_equal 1, page.id
    assert_equal "Home", page.title
  end

  def test_put_page
    page = Radical::Models::Page.parse(file_fixture('page.xml'))
    page.title = 'Huge'
    page.parts[0].content = "Leetsauce"

    Radical::Fetcher.expects(:post).with("/pages/1.xml", {
      :query => {
        '_method' => 'put',
        'page' => {
          'title' => 'Huge',
          'parts_attributes' => {
            '1' => {
              'id' => '1', 'content' => 'Leetsauce',
              'name' => 'body'
            },
            '2' => {
              'id' => '2', 'content' => '',
              'name' => 'extended'
            }
          }
        }
      }
    })
    Radical::Fetcher.put(page)
  end
end
