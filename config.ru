require 'bundler'
require 'rack/sendfile'

require File.join(File.expand_path(File.dirname(__FILE__)), "lib", "imageproxy")
require File.join(File.expand_path(File.dirname(__FILE__)), "lib", "imageproxy", "encryption")

use Imageproxy::Encryption
run Rack::Sendfile.new(Imageproxy::Server.new)