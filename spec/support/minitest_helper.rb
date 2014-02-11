ENV['RACK_ENV'] = "test"

require 'minitest/pride'
require 'minitest/autorun'
require 'awesome_print'

require_relative "../../config/env"

class MiniTest::Spec
  
  after :each do
    Mor.cache.flush
  end
  
end