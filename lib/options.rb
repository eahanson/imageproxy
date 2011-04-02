class Options
  def initialize(query_string)
    params = query_string.split('/').reject { |s| s.nil? || s.empty? }
    root_param = params.shift
    raise NotFound unless root_param == 'convert' || root_param == 'process'
    @hash = Hash[*params]

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
    @hash['source'] = CGI.unescape(@hash['source']) if @hash['source']
  end
end