require 'cgi'
require 'uri'

module Imageproxy
  module RailsHelper
    def imageproxy_thumbnail(source, width, height, shape = :cut)
      raw "/convert?thumbnail=#{width}x#{height}&shape=#{shape}&src=#{CGI.escape(URI.escape(URI.escape(source)))}"
    end
  end
end