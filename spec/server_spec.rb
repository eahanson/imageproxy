require 'spec_helper'

describe "Server" do
  include Rack::Test::Methods

  def app
    Server.new
  end

  context "when converting" do
    it "should send back the right result" do
      get "/convert/resize/10x20/source/#{escaped_test_image_url}"
      last_response.status.should == 200
      Compare.new(response_body_as_file, test_image_path("10x20")).execute.should == "0"
    end
  end

  context "when identifying" do
    it "should send back information about the image" do
      get "/identify/source/#{escaped_test_image_url}"
      last_response.body.should =~ /Format: PNG.*Geometry: 200x116\+0\+0/m
    end
  end

  context "when signature is required" do
    def get_with_signature_required(url)
      get url, {}, { "IMAGEPROXY_SIGNATURE_REQUIRED" => "true", "IMAGEPROXY_SIGNATURE_SECRET" => @secret }
    end

    before do
      @secret = "SEEKRET"      
    end
    
    it "should fail if the signature is missing" do
      get_with_signature_required "/convert/resize/10x20/source/#{escaped_test_image_url}"
      last_response.status.should == 500
    end

    it "should fail if the signature is incorrect" do
      url = "/convert/resize/10x20/source/#{escaped_test_image_url}"
      signature = "BAD"
      get_with_signature_required "#{url}?signature=#{signature}"
      last_response.status.should == 500
    end

    it "should work if the signature is correct" do
      url = "/convert/resize/10x20/source/#{escaped_test_image_url}"
      signature = Signature.create(url, @secret)
      get_with_signature_required "#{url}?signature=#{CGI.escape(signature)}"
      last_response.status.should == 200
    end

    it "should work if the signature is part of the path" do
      url = "/convert/resize/10x20/source/#{escaped_test_image_url}"
      signature = Signature.create(url, @secret)
      get_with_signature_required "#{url}/signature/#{URI.escape(signature)}"
      last_response.status.should == 200
    end
  end
end

