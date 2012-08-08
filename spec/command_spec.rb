require 'spec_helper'

describe Imageproxy::Command do
  describe "#curl" do
    context "when a user agent is supplied" do
      it "should send that user agent" do
        Imageproxy::Command.new.send(:curl, "http://example.com/dog.jpg", :user_agent => "some user agent").should ==
          %|curl -L -f -s -S -A "some user agent" "http://example.com/dog.jpg"|
      end
    end

    context "when no user agent is supplied" do
      it "should send a default user agent" do
        Imageproxy::Command.new.send(:curl, "http://example.com/dog.jpg").should ==
          %|curl -L -f -s -S -A "imageproxy" "http://example.com/dog.jpg"|
      end
    end

    context "when a timeout is supplied" do
      it "should set the timeout" do
        Imageproxy::Command.new.send(:curl, "http://example.com/dog.jpg", :timeout => "2").should ==
          %|curl -m 2 -L -f -s -S -A "imageproxy" "http://example.com/dog.jpg"|
      end
    end

    it "should have curl report errors on stderr" do
      curl_command = Imageproxy::Command.new.send(:curl, "http://example.com/dog.jpg")
      curl_command.should match(/curl .*-f -s -S .*/)
    end

    context "when the command exits with a non-zero status" do
      it "should raise an exception" do
        ruby_19 = RUBY_VERSION.split(".").map(&:to_i)[1] == 9

        if ruby_19
          lambda {
            Imageproxy::Command.new.send(:execute_command, "ls /asdkljasldkjaskl")
          }.should raise_exception
        end
      end
    end
  end
end
