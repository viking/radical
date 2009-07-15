module Radical
  module Models
    class PagePart
      include HappyMapper

      tag :part
      element :id, Integer
      element :name, String
      element :content, String
    end
  end
end