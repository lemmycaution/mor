require 'mor/version'
require 'dalli'

module Mor
  
  @@dalli = {
    compress:     true,
    threadsafe:   true,
    servers:      ENV['MEMCACHIER_SERVERS'],
    password:     ENV['MEMCACHIER_PASSWORD'],
    username:     ENV['MEMCACHIER_USERNAME'],
    async:        true
  }
  
  def self.dalli
    @@dalli
  end
  
  def self.config
    yield self
  end
  
  def self.cache
    @@cache ||= begin
      ::Dalli::Client.new self.dalli["servers"].split(","), self.dalli.reject{|k,v| k == "servers"}
    end
  end
  
end