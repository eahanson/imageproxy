require File.join(File.expand_path(File.dirname(__FILE__)), "options")
require File.join(File.expand_path(File.dirname(__FILE__)), "convert")
require File.join(File.expand_path(File.dirname(__FILE__)), "identify")
require File.join(File.expand_path(File.dirname(__FILE__)), "selftest")
require 'uri'

class Server
  def initialize
    @file_server = Rack::File.new(File.join(File.expand_path(File.dirname(__FILE__)), "..", "public"))
  end
  
  def call(env)
    request = Rack::Request.new(env)
    options = Options.new(request.path_info, request.params)
    user_agent = request.env["HTTP_USER_AGENT"]

    if config?(:signature_required)
      raise "Missing siganture" if options.signature.nil?

      valid_signature = Signature.correct?(options.signature, request.fullpath, config(:signature_secret))
      raise "Invalid signature #{options.signature} for #{request.url}" unless valid_signature
    end

    raise "Invalid domain" unless domain_allowed? options.source
    raise "Image size too large" if exceeds_max_size(options.resize, options.thumbnail)

    case options.command
      when "convert", "process", nil
        file = Convert.new(options).execute(user_agent)
        class << file
          alias to_path path
        end

        file.open
        [200, {"Content-Type" => options.content_type}, file]
      when "identify"
        [200, {"Content-Type" => "text/plain"}, Identify.new(options).execute(user_agent)]
      when "selftest"
        [200, {"Content-Type" => "text/html"}, Selftest.html(request)]
      else
        @file_server.call(env)
    end
  rescue
    STDERR.puts $!
    [500, {"Content-Type" => "text/plain"}, "Error (#{$!})"]
  end

  private

  def config(symbol)
    ENV["IMAGEPROXY_#{symbol.to_s.upcase}"]
  end

  def config?(symbol)
    config(symbol) && config(symbol).casecmp("TRUE") == 0
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
end
