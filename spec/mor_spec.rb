require 'minitest_helper'
require 'mor'

describe Mor do
  
  it "should have a singleton dalli client" do
    Mor.cache.class.must_equal Dalli::Client
  end
  
end