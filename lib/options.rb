class Options
  def initialize(query_string)
    params = query_string.split('/').reject { |s| s.nil? || s.empty? }
    command = params.shift

    @hash = Hash[*params]
    @hash['command'] = command
    unescape_source
  end

  def method_missing(symbol)
    @hash[symbol.to_s]
  end

  def output_mime_type
    "text/plain"
  end

  private
  
  def unescape_source
    if @hash['source']
      @hash['source'] = CGI.unescape(CGI.unescape(@hash['source']))
    end
  end
end