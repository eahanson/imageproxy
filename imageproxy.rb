require 'cgi'
Bundler.require :default

Dir.glob(File.join(File.dirname(__FILE__), "lib", "**", "*.rb")).each {|f| require f }
