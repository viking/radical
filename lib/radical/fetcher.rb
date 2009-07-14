module Radical
  class Fetcher
    include HTTParty
    format :plain

    def self.get_pages
      Page.parse(get("/pages.xml").body)
    end

    def self.get_page(id)
      Page.parse(get("/pages/#{id}.xml").body)
    end

    def self.put_page(page)
      params = { '_method' => 'put', 'page' => { 'title' => page.title } }
      post("/pages/#{page.id}.xml", :query => params)
    end
  end
end
