module Radical
  class Page
    include HappyMapper

    element :id, Integer
    element :title, String
    has_many :parts, PagePart
  end
end
