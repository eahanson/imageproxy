require 'cgi'
require 'mime/types'
Bundler.require :default

require File.join(File.expand_path(File.dirname(__FILE__)), "imageproxy", "server")
