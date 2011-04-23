require 'uri'
require 'cgi'
require 'mime/types'

class Options
  def initialize(path, query_params)
    params_from_path = path.split('/').reject { |s| s.nil? || s.empty? }
    command = params_from_path.shift

    @hash = Hash[*params_from_path]
    @hash['command'] = command
    @hash.merge! query_params
    merge_obfuscated
    @hash["source"] = @hash.delete("src") if @hash.has_key?("src")
    
    unescape_source
    unescape_signature
  end

  def method_missing(symbol)
    @hash[symbol.to_s] || @hash[symbol]
  end

  def content_type
    MIME::Types.of(@hash['source']).first.content_type
  end

  private
  
  def unescape_source
    @hash['source'] &&= CGI.unescape(CGI.unescape(@hash['source']))
  end

  def unescape_signature
    @hash['signature'] &&= URI.unescape(@hash['signature'])
  end

  def merge_obfuscated
    if @hash["_"]
      decoded = Base64.decode64(CGI.unescape(@hash["_"]))
      decoded_hash = CGI.parse(decoded)
      @hash.delete "_"
      decoded_hash.map { |k, v| @hash[k] = (v.class == Array) ? v.first : v }
    end

    if @hash["-"]
      decoded = Base64.decode64(CGI.unescape(@hash["-"]))
      decoded_hash = Hash[*decoded.split('/').reject { |s| s.nil? || s.empty? }]
      @hash.delete "-"
      decoded_hash.map { |k, v| @hash[k] = (v.class == Array) ? v.first : v }
    end
  end
end