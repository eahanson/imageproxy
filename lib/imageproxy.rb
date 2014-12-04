require 'cgi'
require 'mime/types'
require 'figaro'
Figaro.application.path = File.join(File.dirname(__FILE__), '..', 'config', 'application.yml')
Figaro.load
Figaro.require_keys('IMAGEPROXY_SECRET')

Bundler.require :default
require File.join(File.expand_path(File.dirname(__FILE__)), "imageproxy", "server")
