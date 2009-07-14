require 'rubygems'
require 'happymapper'
require 'httparty'

module Radical
  def self.setup(options)
    Fetcher.base_uri options['base_uri']
    Fetcher.basic_auth(options['username'], options['password'])
  end
end

require File.dirname(__FILE__) + "/radical/fetcher"
require File.dirname(__FILE__) + "/radical/models"
require File.dirname(__FILE__) + "/radical/runner"
