ENV['RACK_ENV'] = "test"

require 'minitest/pride'
require 'minitest/autorun'
require 'awesome_print'

require 'mor'

require 'i18n'
I18n.enforce_available_locales = false

Mor.config do |mor|
  mor.dalli['namespace']  = "mor:test"
  mor.dalli['servers']    = "localhost:11211"
end

class MiniTest::Spec
  
  after :each do
    Mor.cache.flush
  end
  
end