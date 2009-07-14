require 'rubygems'
require 'happymapper'
require 'httparty'

require File.dirname(__FILE__) + "/radical/fetcher"
require File.dirname(__FILE__) + "/radical/page_part"
require File.dirname(__FILE__) + "/radical/page"
require File.dirname(__FILE__) + "/radical/runner"

module Radical
  def self.setup(options)
    Fetcher.base_uri options['base_uri']
    Fetcher.basic_auth(options['username'], options['password'])
  end
end
