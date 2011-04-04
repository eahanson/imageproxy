require 'spec_helper'

describe "Server" do
  include Rack::Test::Methods

  def app
    Server.new
  end

  context "when converting" do
    it "should send back a body which responds to to_path for Rack::Sendfile" do
      get "/convert/resize/10x20/source/#{escaped_test_image_url}"
      Compare.new(response_body_as_file, test_image_path("10x20")).execute.should == "0"
    end
  end

  context "when identifying" do
    it "should send back information about the image" do
      get "/identify/source/#{escaped_test_image_url}"
      last_response.body.should =~ /Format: PNG.*Geometry: 200x116\+0\+0/m
    end
  end
end

