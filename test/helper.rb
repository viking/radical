require 'test/unit'
require 'fileutils'
require 'yaml'
require 'rubygems'
require 'mocha'
require 'ruby-debug'

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../lib"))
require 'radical'

def stub_http_response_with(filename)
  format = filename.split('.').last.intern
  data = file_fixture(filename)

  response = Net::HTTPOK.new("1.1", 200, "Content for you")
  response.stubs(:body).returns(data)

  http_request = HTTParty::Request.new(Net::HTTP::Get, 'http://localhost', :format => format)
  http_request.stubs(:perform_actual_request).returns(response)

  HTTParty::Request.stubs(:new).returns(http_request)
end

def file_fixture(filename)
  open(File.join(File.dirname(__FILE__), 'fixtures', "#{filename.to_s}")).read
end
