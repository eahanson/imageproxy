require 'spec_helper'
require 'rack/test'
require 'uri'

describe Imageproxy::Encryption do
  include Rack::Test::Methods

  def app
    @app ||= Imageproxy::Encryption.new(Imageproxy::Server.new)
  end

  let(:request) { "/identify?source=http://wiki.rz.hochschule-trier.de/images/d/dc/Storified_games_example.jpg" }
  let(:request_crypt) { "/VTJGc2RHVmtYMStSNng0ZEFMeURzTnlFNkxvTUY5d1B0TW12SmgrVVluTDEz.NmFXd0VoWVAzd0ZxWUo3CkhBME9weVNCMVp5MTErTjdnRllqOEg0KzVrRzFp.MFJiZExIOFcvSWtqWWFOOVdieGhmbHk1d2FqZ2I3ZwpyM1JGdUdFT2VTTTYz.c2w5Nkx4SldlZllDd3hwWmc9PQo=."}
  let(:broken_crypt) { "/43799fhdsnkw90ru2okjdoshvbdsfalufj0qwunhold" }

  context "plain text request url given" do
    it "should process normally" do
      response = get request
      response.body.should =~ /Image:/
    end
  end

  context "encrypted request_uri is given" do
    it "should process the request" do
      response = get request_crypt
      response.body.should =~ /Image:/
    end
  end

  context "broken encrypted request_uri given" do
    it "should not result in internal server error" do
      response = get broken_crypt
      response.body.should_not =~ /Internal server error/
    end
  end
end