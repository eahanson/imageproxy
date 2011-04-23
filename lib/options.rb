require 'cgi'

class Options
  def initialize(path, query_params)
    params_from_path = path.split('/').reject { |s| s.nil? || s.empty? }
    command = params_from_path.shift

    @hash = Hash[*params_from_path]
    @hash['command'] = command
    @hash.merge! query_params
    @hash["source"] = @hash.delete("src") if @hash.has_key?("src")
    
    unescape_source
  end

  def method_missing(symbol)
    @hash[symbol.to_s] || @hash[symbol]
  end

  def content_type
    MIME::Types.of(@hash['source']).first.content_type
  end

  private
  
  def unescape_source
    if @hash['source']
      @hash['source'] = CGI.unescape(CGI.unescape(@hash['source']))
    end
  end
end