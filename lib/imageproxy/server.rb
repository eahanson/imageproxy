require File.join(File.expand_path(File.dirname(__FILE__)), "options")
require File.join(File.expand_path(File.dirname(__FILE__)), "convert")
require File.join(File.expand_path(File.dirname(__FILE__)), "identify")
require File.join(File.expand_path(File.dirname(__FILE__)), "identify_format")
require File.join(File.expand_path(File.dirname(__FILE__)), "selftest")
require File.join(File.expand_path(File.dirname(__FILE__)), "signature")
require 'uri'

module Imageproxy
  class Server
    def initialize
      @file_server = Rack::File.new(File.join(File.expand_path(File.dirname(__FILE__)), "..", "public"))
    end

    def call(env)
      request = Rack::Request.new(env)
      options = Options.new(request.path_info, request.params)
      user_agent = request.env["HTTP_USER_AGENT"]
      cachetime = config(:cache_time) ? config(:cache_time) : 86400

      case options.command
        when "convert", "process", nil
          check_signature request, options
          check_domain options
          check_size options

          file = convert_file(options, user_agent)
          class << file
            alias to_path path
          end

          file.open
          [200, {"Cache-Control" => "max-age=#{cachetime}, must-revalidate"}.merge(content_type(file, options)), file]
        when "identify"
          check_signature request, options
          check_domain options

          [200, {"Content-Type" => "text/plain"}, [Identify.new(options).execute(user_agent)]]
        when "selftest"
          [200, {"Content-Type" => "text/html"}, [Selftest.html(request, config?(:signature_required), config(:signature_secret))]]
        else
          @file_server.call(env)
      end
    rescue
      STDERR.puts "Request failed: #{options}"
      STDERR.puts $!
      STDERR.puts $!.backtrace.join("\n") if config?(:verbose)
      [500, {"Content-Type" => "text/plain"}, ["Error (#{$!})"]]
    end

    private

    def convert_file(options, user_agent)
      Convert.
        new(options, world_readable_tempfile: config?(:world_readable_tempfile)).
        execute(user_agent, config(:timeout))
    end

    def config(symbol)
      ENV["IMAGEPROXY_#{symbol.to_s.upcase}"]
    end

    def config?(symbol)
      config(symbol) && config(symbol).casecmp("TRUE") == 0
    end

    def check_signature(request, options)
      if config?(:signature_required)
        raise "Missing siganture" if options.signature.nil?

        valid_signature = Signature.correct?(options.signature, request.fullpath, config(:signature_secret))
        raise "Invalid signature #{options.signature} for #{request.url}" unless valid_signature
      end
    end

    def check_domain(options)
      raise "Invalid domain" unless domain_allowed? options.source
    end

    def check_size(options)
      raise "Image size too large" if exceeds_max_size(options.resize, options.thumbnail)
    end

    def domain_allowed?(url)
      return true unless allowed_domains
      allowed_domains.include?(url_to_domain url)
    end

    def url_to_domain(url)
      URI::parse(url).host.split(".")[-2, 2].join(".")
    rescue
      ""
    end

    def allowed_domains
      config(:allowed_domains) && config(:allowed_domains).split(",").map(&:strip)
    end

    def exceeds_max_size(*sizes)
      max_size && sizes.any? { |size| size && requested_size(size) > max_size }
    end

    def max_size
      config(:max_size) && config(:max_size).to_i
    end

    def requested_size(req_size)
      sizes = req_size.scan(/\d*/)
      if sizes[2] && (sizes[2].to_i > sizes[0].to_i)
        sizes[2].to_i
      else
        sizes[0].to_i
      end
    end

    def content_type(file, options)
      format = options.format
      format = identify_format(file) unless format
      format = options.source unless format
      format ? { "Content-Type" => MIME::Types.of(format).first.content_type } : {}
    end

    def identify_format(file)
      Imageproxy::IdentifyFormat.new(file).execute
    end
  end
end
