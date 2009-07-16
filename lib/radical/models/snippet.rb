module Radical
  module Models
    class Snippet
      include Base
      element :id, Integer
      element :name, String
      element :content, String
    end
  end
end
