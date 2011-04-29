require File.join(File.expand_path(File.dirname(__FILE__)), "options")
require File.join(File.expand_path(File.dirname(__FILE__)), "convert")
require File.join(File.expand_path(File.dirname(__FILE__)), "identify")
require 'uri'

class Server
  def call(env)
    request = Rack::Request.new(env)
    options = Options.new(request.path_info, request.params)
    user_agent = request.env["HTTP_USER_AGENT"]
    domain = url_to_domain(options.source)

    request.env["IMAGEPROXY_ALLOWED_DOMAINS"] = ENV['IMAGEPROXY_ALLOWED_DOMAINS']
    request.env["IMAGEPROXY_MAX_SIZE"] = ENV['IMAGEPROXY_MAX_SIZE']
    request.env["IMAGEPROXY_CACHE_TIME"] = ENV['IMAGEPROXY_CACHE_TIME']

    cachetime = request.env["IMAGEPROXY_CACHE_TIME"].to_i

    if signature_required?(request)
      raise "Missing siganture" if options.signature.nil?

      valid_signature = Signature.correct?(options.signature, request.fullpath, request.env["IMAGEPROXY_SIGNATURE_SECRET"])
      raise "Invalid signature #{options.signature} for #{request.url}" unless valid_signature
    end

    if domains = domain_restricted(request)
      raise "Wrong domain" unless domains.include? domain
    end

    if max_size = size_restricted(request)
      raise "Image size too large" unless requested_size(options.resize) < max_size
    end

    case options.command
      when "convert", "process", nil
        file = Convert.new(options).execute(user_agent)
        class << file
          alias to_path path
        end

        file.open
        [200, {"Content-Type" => options.content_type, "Cache-Control" => "max-age=#{cachetime}, must-revalidate"}, file]
      when "identify"
        [200, {"Content-Type" => "text/plain"}, Identify.new(options).execute(user_agent)]
      else
        [404, {"Content-Type" => "text/plain"}, "Not found"]
    end
  rescue
    STDERR.puts $!
    [500, {"Content-Type" => "text/plain"}, "Sorry, an internal error occurred"]
  end

  private

  def signature_required?(request)
    required = request.env["IMAGEPROXY_SIGNATURE_REQUIRED"]
    required != nil && required.casecmp("TRUE") == 0
  end

  def domain_restricted(request)
    domains = request.env["IMAGEPROXY_ALLOWED_DOMAINS"].nil? ? false : request.env["IMAGEPROXY_ALLOWED_DOMAINS"].split(',')
  end

  def size_restricted(request)
    max_size = request.env["IMAGEPROXY_MAX_SIZE"].nil? ? false : request.env["IMAGEPROXY_MAX_SIZE"].to_i
  end

  def url_to_domain(url)
    begin
      URI::parse( url ).host.split( "." )[-2,2].join(".")
    rescue
      ""
    end
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
