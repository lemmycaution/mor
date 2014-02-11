require 'yaml'
require 'erb'
require 'dalli'

module Mor
  module Client
  
    def cache
      @@cache ||= begin
        config = YAML::load(ERB.new(File.read("config/cache.yml")).result)[Mor.env]
        @instance = Dalli::Client.new config.delete("servers").split(","), config
      end
    end
    
  end
end