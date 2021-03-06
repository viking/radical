module Radical
  module Models
    class PagePart
      include Base
      tag :part
      element :id, Integer
      element :name, String
      element :content, String
    end
  end
end
