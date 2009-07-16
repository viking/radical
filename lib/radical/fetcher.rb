module Radical
  class Fetcher
    include HTTParty
    format :plain

    class << self
      alias :original_get :get
      def get(type, which)
        klass = Models.const_get(type.to_s.capitalize)
        base = base_for(type)
        url = (which == :all) ? "#{base}.xml" : "#{base}/#{which}.xml"
        klass.parse(original_get(url).body)
      end

      alias :original_put :put
      def put(item)
        type = item.class.to_s.split("::")[-1].downcase
        params = {
          '_method' => 'put', type => item.to_params
        }
        params[type].delete('id')

        url = "#{base_for(type)}/#{item.id}.xml"
        post(url, :query => params)
      end

      private
        def base_for(type)
          case type
          when :page,    'page'    then "/pages"
          when :layout,  'layout'  then "/layouts"
          when :snippet, 'snippet' then "/snippets"
          end
        end
    end
  end
end
