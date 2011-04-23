require 'spec_helper'

describe Signature do
  describe "#create" do
    it "should create a signature from a query string" do
      Signature.create("/convert?src=http://www.example.com/dog.jpg&resize=400x400&signature=AAA&key=BBB", "SECRET").should_not be_nil
    end

    it "should ignore the signature param" do
      Signature.create("/convert?src=SRC&resize=10x10&signature=SIG&key=KEY", "SECRET").should == Signature.create("/convert?src=SRC&resize=10x10&key=KEY", "SECRET")
    end
  end

  describe "#correct?" do
    it "should validate a signature" do
      Signature.correct?(Signature.create("/convert?src=SRC&resize=10x10&key=KEY", "SECRET"), "/convert?src=SRC&resize=10x10&key=KEY", "SECRET").should be_true
    end

    it "should return false if signature is nil" do
      Signature.correct?(nil, "/convert?src=SRC&resize=10x10&key=KEY", "SECRET").should be_false
    end
  end

  describe "#remove_signature_from" do
    it "should remove the signature when it's the only query param" do
      Signature.remove_signature_from("/convert/a/apple/b/banana?signature=SIG").should ==
        "/convert/a/apple/b/banana"
    end

    it "should remove the signature from the beginning of the query string" do
      Signature.remove_signature_from("/convert/a/apple/b/banana?signature=SIG&c=cherry&d=donut").should == 
        "/convert/a/apple/b/banana?c=cherry&d=donut"
    end
    
    it "should remove the signature from the middle of the query string" do
      Signature.remove_signature_from("/convert/a/apple/b/banana?c=cherry&signature=SIG&d=donut").should == 
        "/convert/a/apple/b/banana?c=cherry&d=donut"
    end
    
    it "should remove the signature from the end of the query string" do
      Signature.remove_signature_from("/convert/a/apple/b/banana?c=cherry&d=donut&signature=SIG").should == 
        "/convert/a/apple/b/banana?c=cherry&d=donut"
    end
  end
end
