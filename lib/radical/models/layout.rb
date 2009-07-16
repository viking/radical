module Radical
  module Models
    class Layout
      include Base
      element :id, Integer
      element :name, String
      element :content, String
    end
  end
end
