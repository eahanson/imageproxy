require 'spec_helper'

describe Imageproxy::Command do
  describe "#curl" do
    context "when a user agent is supplied" do
      it "should send that user agent" do
        Imageproxy::Command.new.send(:curl, "http://example.com/dog.jpg", :user_agent => "some user agent").should ==
          %|curl -L -s -A "some user agent" "http://example.com/dog.jpg"|
      end
    end

    context "when no user agent is supplied" do
      it "should send a default user agent" do
        Imageproxy::Command.new.send(:curl, "http://example.com/dog.jpg").should ==
          %|curl -L -s -A "imageproxy" "http://example.com/dog.jpg"|
      end
    end
  end
end
