require 'spec_helper'

describe Convert do
  before do
    @mock_file = mock("file")
    @mock_file.stub!(:path).and_return("/mock/file/path")

    @command = Convert.new(Options.new("/convert/resize/10x20/source/http%3A%2F%2Fexample.com%2Fdog.jpg", {}))
    @command.stub!(:file).and_return(@mock_file)
    @command.stub!(:system)
  end

  context "when resizing" do
    it "should execute the correct command" do
      @command.should_receive(:execute_command).with(%'curl -s "http://example.com/dog.jpg" | convert - -resize 10x20 /mock/file/path')
      @command.execute
    end

    it "should return the output file" do
      @command.execute.should == @mock_file
    end
  end
end
