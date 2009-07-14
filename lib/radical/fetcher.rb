module Radical
  class Fetcher
    include HTTParty
    format :plain

    def self.get_pages
      Models::Page.parse(get("/pages.xml").body)
    end

    def self.get_page(id)
      Models::Page.parse(get("/pages/#{id}.xml").body)
    end

    def self.put_page(page)
      params = { '_method' => 'put', 'page' => { 'title' => page.title } }

      parts = {}
      page.parts.each do |part|
        parts[parts.length.to_s] = {
          'id' => part.id, 'content' => part.content
        }
      end
      params['page']['parts_attributes'] = parts

      post("/pages/#{page.id}.xml", :query => params)
    end
  end
end
