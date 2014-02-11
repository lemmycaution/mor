# real time stdout
$stdout.sync = true

%w(. lib).each do |dir|
  path = File.expand_path( "../../#{dir}", __FILE__)
  $LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
end

require 'bundler/setup'
Bundler.setup

require 'i18n'
I18n.enforce_available_locales = false