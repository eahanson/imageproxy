require 'spec_helper'

describe Command do
  context "when resizing" do
    it "should execute the correct command" do
      command = Command.new(Options.new("/resize/10x20/source/http%3A%2F%2Fexample.com%2Fdog.jpg")).command
      command.should == 'curl -s "http://example.com/dog.jpg" | convert - -resize 10x20 dest.jpg'
    end
  end
end