module Radical
  module Models
    class Page
      include Base
      element :id, Integer
      element :title, String
      has_many :parts, PagePart
    end
  end
end
