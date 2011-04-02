Bundler.require :test
require File.dirname(__FILE__) + "/../imageproxy"

def response_body_as_file
  result_file = Tempfile.new("request_spec")
  result_file.write(last_response.body)
  result_file.close
  result_file
end

def test_image_path(size=nil)
  size_suffix = size.nil? ? "" : "_#{size}"
  File.expand_path(File.dirname(__FILE__) + "/../test_images/dog#{size_suffix}.png")
end

def test_image_url
  "file://#{test_image_path}"
end

def escaped_test_image_url
  CGI.escape test_image_url
end
