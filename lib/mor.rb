require 'mor/version'
require 'mor/client'

module Mor
  
  def self.env
    ENV['RACK_ENV'] ||= "development"
  end
  
  extend Client
  
end