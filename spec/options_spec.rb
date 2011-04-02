require "#{File.dirname(__FILE__)}/../imageproxy"

describe "parsing" do
  context "a simple URL" do
    subject { Options.new "/process/color/blue/size/medium" }
    its(:color) { should == "blue" }
    its(:size) { should == "medium" }
  end

  context "root directory" do
    it "can be 'process'" do
      lambda { Options.new "/process/foo/bar" }.should_not raise_exception
    end

    it "can be 'convert'" do
      lambda { Options.new "/convert/foo/bar" }.should_not raise_exception
    end

    it "raises an error otherwise" do
      lambda { Options.new "/peanut/foo/bar" }.should raise_exception
    end
  end

  context "source" do
    context "when escaped" do
      subject { Options.new "/process/source/http%3A%2F%2Fexample.com%2Fdog.jpg" }
      it("should unescape") { subject.source.should == "http://example.com/dog.jpg" }
    end

    context "when not escaped" do
      subject { Options.new "/process/source/foo" }
      it("should not unescape") { subject.source.should == "foo" }
    end
  end
end