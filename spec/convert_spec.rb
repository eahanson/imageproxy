require 'spec_helper'

describe Imageproxy::Convert do
  before do
    @mock_file = mock("file")
    @mock_file.stub!(:path).and_return("/mock/file/path")
  end

  def command(options)
    command = Imageproxy::Convert.new(Imageproxy::Options.new("", {:source => "http%3A%2F%2Fexample.com%2Fdog.jpg"}.merge(options)))
    command.stub!(:file).and_return(@mock_file)
    command.stub!(:system)
    command
  end

  context "general" do
    before do
      @command = Imageproxy::Convert.new(Imageproxy::Options.new("/convert/format/png/resize/10x20/source/http%3A%2F%2Fexample.com%2Fdog.jpg", {}))
      @command.stub!(:file).and_return(@mock_file)
      @command.stub!(:system)
    end

    it "should generate the proper command-line" do
      @command.should_receive(:execute_command).with(
          %'curl -L -f -s -S -A "imageproxy" "http://example.com/dog.jpg" | convert - -resize 10x20 png:/mock/file/path')
      @command.execute
    end

    it "should return the output file" do
      @command.stub!(:execute_command)
      @command.execute.should == @mock_file
    end
  end

  describe "#file" do
    it "should create a world-readable tempfile if requested" do
      convert = Imageproxy::Convert.new(
        Imageproxy::Options.new("", {:resize=> "20x20", :source => "http%3A%2F%2Fexample.com%2Fdog.jpg"}),
        world_readable_tempfile: true)
      mock_file = mock("Tempfile", close: nil, path: "")
      mock_file.should_receive(:chmod).with(0644)
      Tempfile.should_receive(:new).and_return(mock_file)
      convert.file
    end
  end

  context "when resizing" do
    it("with no extra args") do
      command(:resize => "10x20").convert_options.should ==
        '-resize 10x20'
    end

    it("with a different size") do
      command(:resize => "50x50").convert_options.should ==
        '-resize 50x50'
    end

    it("when preserving shape") do
      command(:resize => "10x20", :shape => "preserve").convert_options.should ==
        '-resize 10x20'
    end

    it("when padding") do
      command(:resize => "10x20", :shape => "pad").convert_options.should ==
        '-resize 10x20 -background none -matte -gravity center -extent 10x20'
    end

    it("when padding with a background color") do
      command(:resize => "10x20", :shape => "pad", :background => "#ff00ff").convert_options.should ==
        '-resize 10x20 -background "#ff00ff" -gravity center -extent 10x20'
    end

    it("when cutting") do
      command(:resize => "10x20", :shape => "cut").convert_options.should ==
        '-resize 10x20^ -background none -matte -gravity center -extent 10x20'
    end
  end

  context "when thumbnailing" do
    it("when preserving shape") do
      command(:thumbnail => "10x20", :shape => "preserve").convert_options.should ==
        '-thumbnail 10x20'
    end

    it("when padding") do
      command(:thumbnail => "10x20", :shape => "pad", :background => "#ff00ff").convert_options.should ==
        '-thumbnail 10x20 -background "#ff00ff" -gravity center -extent 10x20'
    end

    it("when cutting") do
      command(:thumbnail => "10x20", :shape => "cut").convert_options.should ==
        '-thumbnail 10x20^ -background none -matte -gravity center -extent 10x20'
    end
  end

  context "when flipping" do
    it("should flip horizontal") do
      command(:flip => "horizontal").convert_options.should ==
        "-flop"
    end

    it("should flip vertical") do
      command(:flip => "vertical").convert_options.should ==
        "-flip"
    end
  end

  context "when rotating" do
    it("should rotate to a right angle") do
      command(:rotate => "90").convert_options.should ==
        "-rotate 90"
    end

    it("should rotate to a non-right angle") do
      command(:rotate => "92.1").convert_options.should ==
        "-background none -matte -rotate 92.1"
    end

    it("should rotate to a non-right angle with a background") do
      command(:rotate => "92.1", :background => "#ff00ff").convert_options.should ==
        '-background "#ff00ff" -matte -rotate 92.1'
    end
  end

  context "when changing format" do
    it("should not change the format if not requested") do
      command(:rotate => "90").new_format.should ==
        ""
    end

    it("should not change the format if not requested") do
      command(:rotate => "90", :format => "png").new_format.should ==
        "png:"
    end

    it("should set the colors when converting to png8") do
      command(:rotate => "90", :format => "png8").convert_options.should ==
        "-rotate 90 -colors 256"
    end
  end

  context "when changing quality" do
    it("should set the quality") do
      command(:quality => "85").convert_options.should ==
        "-quality 85"
    end
  end

  context "when converting to progressive" do
    it("should be 'JPEG' if progressive is 'true'") do
      command(:resize => "10x10", :progressive => "true").convert_options.should ==
        "-resize 10x10 -interlace JPEG"
    end

    it("should be 'none' if progressive is 'false'") do
      command(:resize => "10x10", :progressive => "false").convert_options.should ==
        "-resize 10x10 -interlace none"
    end

    it("should not be set if progressive isn't supplied") do
      command({:resize => "10x10"}).convert_options.should_not match /interlace/
    end
  end

  context "when compositing" do
    before do
      @command = command("overlay" => "http%3A%2F%2Fexample.com%2Fframe.jpg")
      @command.stub!(:file).and_return(@mock_file)
      @command.stub!(:system)
    end

    it "should fetch both the overlay and the source, and call the composite command to composit the overlay on top of the source" do
      @command.should_receive(:execute_command).with(%r|curl -L -f -s -S -A "imageproxy" -o [^ ]+ "http://example.com/frame.jpg"|)
      @command.should_receive(:execute_command).with(
        %r{curl -L -f -s -S -A "imageproxy" "http://example.com/dog.jpg" | composite [^ ]+ - - | convert - png:/mock/file/path})
      @command.execute
    end

    it "should return the output file" do
      @command.stub!(:execute_command)
      @command.execute.should == @mock_file
    end
  end
end
