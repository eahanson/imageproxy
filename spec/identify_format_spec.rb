require 'spec_helper'

describe Imageproxy::IdentifyFormat do
  before do
    @mock_file = mock("file")
    @mock_file.stub!(:path).and_return("/tmp/foo")
  end

  context "when the format looks valid" do
    it "should return the format" do
      command = Imageproxy::IdentifyFormat.new(@mock_file)
      command.stub!(:execute_command).and_return("JPEG")
      command.execute.should == "JPEG"
    end
  end

  context "when the format looks like an error message" do
    it "should return nil" do
      command = Imageproxy::IdentifyFormat.new(@mock_file)
      command.stub!(:execute_command).and_return("identify: some error message")
      command.execute.should == nil
    end
  end
end