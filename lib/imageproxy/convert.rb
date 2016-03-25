require File.join(File.expand_path(File.dirname(__FILE__)), "command")
require "timeout"

module Imageproxy
  class Convert < Imageproxy::Command
    attr_reader :options

    def initialize(options, settings={})
      @options = options
      @settings = settings

      if (!(options.resize || options.thumbnail || options.rotate || options.flip || options.format ||
        options.quality || options.overlay))
        raise "Missing action or illegal parameter value"
      end
    end

    def execute(user_agent=nil, timeout=nil)
      if options.overlay
        @overlay_file ||= Tempfile.new("imageproxy").tap(&:close)
        try_command_with_timeout(curl options.overlay, :user_agent => user_agent, :timeout => timeout, :authInfo => options.authInfo, :language => options.language, :output => @overlay_file.path)
        try_command_with_timeout curl(options.source, :user_agent => user_agent, :timeout => timeout, :authInfo => options.authInfo, :language => options.language) +
                          "| composite #{@overlay_file.path} - - | convert - #{convert_options} #{new_format}#{file.path}"
        file
      else
        try_command_with_timeout %'#{curl options.source, :user_agent => user_agent, :timeout => timeout, :authInfo => options.authInfo, :language => options.language} | convert - #{convert_options} #{new_format}#{file.path}'
        file
      end
    end

    def try_command_with_timeout cmd
      Timeout::timeout(10) { execute_command cmd }
    rescue Timeout::Error => e
      puts "Command timed out after 10 seconds, retrying >#{cmd}<"
      execute_command cmd
      puts "SUCCESS " * 20
    rescue Exception => e
      puts "Error while retrieving #{options.source}"
      execute_command %'convert #{Dir.pwd}/public/noImage.png #{convert_options} #{new_format}#{file.path}'
    end

    def convert_options
      convert_options = []
      convert_options << "-resize #{resize_thumbnail_options(options.resize)}" if options.resize
      convert_options << "-thumbnail #{resize_thumbnail_options(options.thumbnail)}" if options.thumbnail
      convert_options << "-flop" if options.flip == "horizontal"
      convert_options << "-flip" if options.flip == "vertical"
      convert_options << rotate_options if options.rotate
      convert_options << "-colors 256" if options.format == "png8"
      convert_options << "-quality #{options.quality}" if options.quality
      convert_options << interlace_options if options.progressive
      convert_options.join " "
    end

    def resize_thumbnail_options(size)
      case options.shape
        when "cut"
          background = options.background ? %|"#{options.background}"| : %|none -matte|
          "#{size}^ -background #{background} -gravity center -extent #{size}"
        when "preserve"
          size
        when "preserve-not-enlarge"
          "#{size}\\\> "
        when "pad"
          background = options.background ? %|"#{options.background}"| : %|none -matte|
          "#{size} -background #{background} -gravity center -extent #{size}"
        else
          size
      end
    end

    def rotate_options
      if options.rotate.to_f % 90 == 0
        "-rotate #{options.rotate}"
      else
        background = options.background ? %|"#{options.background}"| : %|none|
        "-background #{background} -matte -rotate #{options.rotate}"
      end
    end

    def interlace_options
      case options.progressive
        when "true"
          "-interlace JPEG"
        when "false"
          "-interlace none"
        else
          ""
      end
    end

    def new_format
      options.format ? "#{options.format}:" : ""
    end
    
    def file
      @tempfile ||= begin
        file = Tempfile.new("imageproxy")
        file.chmod 0644 if @settings[:world_readable_tempfile]
        file.close
        file
      end
    end
  end
end
