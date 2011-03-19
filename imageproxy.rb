require 'cgi'

Dir.glob(File.join(File.join(File.dirname(__FILE__), "lib"), "**/*.rb")).each {|f| require f }
