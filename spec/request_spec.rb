require 'spec_helper'

describe "Request" do
  include Rack::Test::Methods

  def app
    Server.new
  end

  it "should send back a body which responds to to_path for Rack::Sendfile" do
    get "/convert/resize/10x20/source/#{escaped_test_image_url}"
    Compare.new(response_body_as_file, test_image_path("10x20")).execute.should == "0"
  end
end
