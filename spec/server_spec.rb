require 'spec_helper'

describe "Server" do
  include Rack::Test::Methods

  RSpec::Matchers.define :succeed do
    match do |actual|
      actual.status == 200
    end
  end

  RSpec::Matchers.define :fail do
    match do |actual|
      actual.status == 500
    end
  end

  def app
    @app ||= Imageproxy::Server.new
  end

  context "when converting" do
    it "should send back the right result" do
      app.stub!(:config) { |sym| nil }
      get("/convert/resize/10x20/source/#{escaped_test_image_url}").should succeed
      Imageproxy::Compare.new(response_body_as_file, test_image_path("10x20")).execute.should == "0"
    end
  end

  context "when identifying" do
    it "should send back information about the image" do
      app.stub!(:config) { |sym| nil }
      get "/identify/source/#{escaped_test_image_url}"
      last_response.body.should =~ /Format: PNG.*Geometry: 200x116\+0\+0/m
    end
  end

  context "when signature is required" do
    before do
      @secret = "SEEKRET"
      app.stub!(:config) { |sym| {:signature_required => "true", :signature_secret => @secret}[sym] }
    end

    it "should fail if the signature is missing" do
      get("/convert/resize/10x20/source/#{escaped_test_image_url}").should fail
    end

    it "should fail if the signature is incorrect" do
      url = "/convert/resize/10x20/source/#{escaped_test_image_url}"
      signature = "BAD"
      get("#{url}?signature=#{signature}").should fail
    end

    it "should work if the signature is correct" do
      url = "/convert/resize/10x20/source/#{escaped_test_image_url}"
      signature = Imageproxy::Signature.create(url, @secret)
      get("#{url}?signature=#{CGI.escape(signature)}").should succeed
    end

    it "should work if the signature is part of the path" do
      url = "/convert/resize/10x20/source/#{escaped_test_image_url}"
      signature = Imageproxy::Signature.create(url, @secret)
      get("#{url}/signature/#{URI.escape(signature)}").should succeed
    end
  end

  context "when limiting to certain domains" do
    before do
      app.stub!(:config) { |sym| {:allowed_domains => " example.com  ,example.org"}[sym] }
      app.stub!(:convert_file).and_return(Tempfile.new("fooo"))
      app.stub!(:content_type).and_return({ "Content-Type" => "image/jpeg"})
    end

    it "should parse the allowed domains" do
      app.send(:allowed_domains).should =~ ["example.com", "example.org"]
    end

    it "should only examine the second-level domain" do
      app.send(:url_to_domain, "http://foo.bar.example.com/something").should == "example.com"
    end

    it "should fail if the source domain is not in the allowed domains" do
      get("/convert/resize/10x20/source/#{CGI.escape('http://example.net/dog.jpg')}").should fail
    end

    it "should pass if the source domain is in the allowed domains" do
      get("/convert/resize/10x20/source/#{CGI.escape('http://example.org/dog.jpg')}").should succeed
    end
  end

  context "when limiting to a maximum size" do
    before do
      app.stub!(:config) { |sym| { :max_size => "50" }[sym] }
    end

    it "should parse out the larger dimension" do
      app.send(:requested_size, "10x50").should == 50
      app.send(:requested_size, "50x50").should == 50
      app.send(:requested_size, "50").should == 50
    end
    
    it "should pass when converting to a smaller size" do
      get("/convert/resize/20x20/source/#{escaped_test_image_url}").should succeed
    end

    it "should pass when converting to the max size" do
      get("/convert/resize/50x50/source/#{escaped_test_image_url}").should succeed
    end

    it "should fail when converting to a larger size" do
      get("/convert/resize/50x51/source/#{escaped_test_image_url}").should fail
    end

    it "should pass when thumbnailing to a smaller size" do
      get("/convert/thumbnail/20x20/source/#{escaped_test_image_url}").should succeed
    end

    it "should fail when thumbnailing to a larger size" do
      get("/convert/thumbnail/50x51/source/#{escaped_test_image_url}").should fail
    end

  end

  context "error handling on errors from curl" do
    it "should fail if curl can't load from that URL" do
      get("/convert/flip/vertical/source/#{escaped_test_broken_image_url}").should fail
    end

    it "should succeed if curl can load from that URL" do
      get("/convert/flip/vertical/source/#{escaped_test_image_url}").should succeed
    end
  end

  describe "#content_type" do
    before do
      @options = Imageproxy::Options.new("/", {})

      @mock_file = mock("file")
      @mock_file.stub!(:path).and_return("/tmp/foo")

      @mock_identify_format = Imageproxy::IdentifyFormat.new(@mock_file)
      @mock_identify_format.stub!(:execute_command).and_return("identify: some error message\n")
      Imageproxy::IdentifyFormat.stub!(:new).and_return(@mock_identify_format)
    end

    context "when the output format is specified" do
      it "should return that format's mime type" do
        @options = Imageproxy::Options.new("/", :format => "jpg")
        app.send(:content_type, @mock_file, @options).should == { "Content-Type" => "image/jpeg" }
      end
    end

    context "when 'identify' knows the format" do
      it "should return that format's mime type" do
        @mock_identify_format.stub!(:execute_command).and_return("JPEG\n")
        app.send(:content_type, @mock_file, @options).should == { "Content-Type" => "image/jpeg" }
      end
    end

    context "when the input source has a file extension" do
      it "should return that format's mime type" do
        @options = Imageproxy::Options.new("/", :source => "foo.jpg")
        app.send(:content_type, @mock_file, @options).should == { "Content-Type" => "image/jpeg" }
      end
    end

    context "when nothing is known about the format" do
      it "should not return a mime type" do
        app.send(:content_type, @mock_file, @options).should == {}
      end
    end

  end
end

