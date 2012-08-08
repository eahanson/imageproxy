Bundler.require :test

Dir.glob(File.join(File.dirname(__FILE__), "..", "lib", "**", "*.rb")).each {|f| require f }

def response_body_as_file
  result_file = Tempfile.new("request_spec")
  result_file.write(last_response.body)
  result_file.close
  result_file
end

def test_image_path(size=nil)
  size_suffix = size.nil? ? "" : "_#{size}"
  File.expand_path(File.dirname(__FILE__) + "/../public/sample#{size_suffix}.png")
end

def test_image_url
  "file://#{test_image_path}"
end

def escaped_test_image_url
  CGI.escape test_image_url
end

def test_broken_image_path
  File.expand_path(File.dirname(__FILE__) + "/../public/does-not-exist.png")
end

def test_broken_image_url
  "file://#{test_broken_image_path}"
end

def escaped_test_broken_image_url
  CGI.escape test_broken_image_url
end
