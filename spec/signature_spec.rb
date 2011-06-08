require 'spec_helper'

describe Imageproxy::Signature do
  describe "#create" do
    it "should create a signature from a query string" do
      Imageproxy::Signature.create("/convert?src=http://www.example.com/dog.jpg&resize=400x400&signature=AAA&key=BBB", "SECRET").should_not be_nil
    end

    it "should ignore the signature param" do
      Imageproxy::Signature.create("/convert?src=SRC&resize=10x10&signature=SIG&key=KEY", "SECRET").should == Imageproxy::Signature.create("/convert?src=SRC&resize=10x10&key=KEY", "SECRET")
    end
  end

  describe "#correct?" do
    it "should validate a signature" do
      Imageproxy::Signature.correct?(Imageproxy::Signature.create("/convert?src=SRC&resize=10x10&key=KEY", "SECRET"), "/convert?src=SRC&resize=10x10&key=KEY", "SECRET").should be_true
    end

    it "should return false if signature is nil" do
      Imageproxy::Signature.correct?(nil, "/convert?src=SRC&resize=10x10&key=KEY", "SECRET").should be_false
    end

    it "should handle URL-safe signatures" do
      Imageproxy::Signature.correct?("_v70E0zfdcRR4cJehS2mhvqJ-8s=", "YLANEBHFSJGCAWKDNCKWEKJRXKPMYU", "SECRET").should be_true
    end

    it "should handle non-URL-safe signatures" do
      Imageproxy::Signature.correct?("k7DMQ/G8YAsbSovX+mDFjlHHMjo=", "YPMMYCRRECCCIPSXPDDFIJFSINOIRC", "SECRET").should be_true
    end
  end

  describe "#remove_signature_from" do
    it "should remove the signature when it's the only query param" do
      Imageproxy::Signature.remove_signature_from("/convert/a/apple/b/banana?signature=SIG").should ==
        "/convert/a/apple/b/banana"
    end

    it "should remove the signature from the beginning of the query string" do
      Imageproxy::Signature.remove_signature_from("/convert/a/apple/b/banana?signature=SIG&c=cherry&d=donut").should ==
        "/convert/a/apple/b/banana?c=cherry&d=donut"
    end
    
    it "should remove the signature from the middle of the query string" do
      Imageproxy::Signature.remove_signature_from("/convert/a/apple/b/banana?c=cherry&signature=SIG&d=donut").should ==
        "/convert/a/apple/b/banana?c=cherry&d=donut"
    end
    
    it "should remove the signature from the end of the query string" do
      Imageproxy::Signature.remove_signature_from("/convert/a/apple/b/banana?c=cherry&d=donut&signature=SIG").should ==
        "/convert/a/apple/b/banana?c=cherry&d=donut"
    end

    it "should remove the signature from the beginning of the path" do
      Imageproxy::Signature.remove_signature_from("/convert/signature/SIG/a/apple/b/banana?c=cherry&d=donut").should ==
        "/convert/a/apple/b/banana?c=cherry&d=donut"
    end

    it "should remove the signature from the middle of the path" do
      Imageproxy::Signature.remove_signature_from("/convert/a/apple/signature/SIG/b/banana?c=cherry&d=donut").should ==
        "/convert/a/apple/b/banana?c=cherry&d=donut"
    end

    it "should remove the signature from the end of the path" do
      Imageproxy::Signature.remove_signature_from("/convert/a/apple/b/banana/signature/SIG?c=cherry&d=donut").should ==
        "/convert/a/apple/b/banana?c=cherry&d=donut"
    end

    it "should remove the signature from the end of the path when there's no query string" do
      Imageproxy::Signature.remove_signature_from("/convert/a/apple/b/banana/signature/SIG").should ==
        "/convert/a/apple/b/banana"
    end
  end
end

