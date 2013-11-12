$stdout.sync = true
require "#{File.dirname(__FILE__)}/initializer"
require "#{File.dirname(__FILE__)}/web"
run Sinatra::Application