require 'bundler'
require 'rack/sendfile'

require File.join(File.expand_path(File.dirname(__FILE__)), "imageproxy")
require File.join(File.expand_path(File.dirname(__FILE__)), "lib", "server")

run Rack::Sendfile.new(Server.new)