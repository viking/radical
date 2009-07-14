module Radical
  class Base < ActiveResource::Base
    self.site = "http://localhost:3000/admin/"
    self.user = "admin"
    self.password = "radiant"
  end
end
