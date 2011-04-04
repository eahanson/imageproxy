require 'cgi'
require 'mime/types'
Bundler.require :default

Dir.glob(File.join(File.dirname(__FILE__), "lib", "**", "*.rb")).each {|f| require f }
