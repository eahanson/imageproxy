require 'spec_helper'

describe Command do
  describe "#curl" do
    context "when a user agent is supplied" do
      it "should send that user agent" do
        Command.new.send(:curl, "http://example.com/dog.jpg", :user_agent => "some user agent").should ==
          %|curl -s -A "some user agent" "http://example.com/dog.jpg"|
      end
    end

    context "when no user agent is supplied" do
      it "should send a default user agent" do
        Command.new.send(:curl, "http://example.com/dog.jpg").should ==
          %|curl -s -A "imageproxy" "http://example.com/dog.jpg"|
      end
    end
  end
end
