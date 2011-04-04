require "#{File.dirname(__FILE__)}/../imageproxy"

describe Options do
  describe "parsing path" do
    context "a simple URL" do
      subject { Options.new "/process/color/blue/size/medium", {} }
      its(:command) { should == "process" }
      its(:color) { should == "blue" }
      its(:size) { should == "medium" }
    end

    context "source" do
      context "when double-escaped" do
        subject { Options.new "/process/source/http%253A%252F%252Fexample.com%252Fdog.jpg", {} }
        it("should unescape") { subject.source.should == "http://example.com/dog.jpg" }
      end

      context "when escaped" do
        subject { Options.new "/process/source/http%3A%2F%2Fexample.com%2Fdog.jpg", {} }
        it("should unescape") { subject.source.should == "http://example.com/dog.jpg" }
      end

      context "when not escaped" do
        subject { Options.new "/process/source/foo", {} }
        it("should not unescape") { subject.source.should == "foo" }
      end
    end
  end

  describe "adding query params" do
    subject { Options.new "/convert/source/foo", { "resize" => "20x20" } }
    it("should add query params") { subject.resize.should == "20x20" }
    it("should keep params from path") { subject.source.should == "foo" }
  end

  describe "content type" do
    context "when guessing based on source filename" do
      it("should understand .png") { Options.new("/convert", "source" => "foo.png").content_type.should == "image/png" }
      it("should understand .jpg") { Options.new("/convert", "source" => "foo.jpg").content_type.should == "image/jpeg" }
      it("should understand .JPEG") { Options.new("/convert", "source" => "foo.JPEG").content_type.should == "image/jpeg" }
    end
  end
end
