class Options
  def initialize(query_string)
    params = query_string.split('/').reject { |s| s.nil? || s.empty? }
    @hash = Hash[*params]

    unescape_source
  end

  def [](key)
    @hash[key.to_s]
  end
  
  def unescape_source
    return unless @hash['source']
    @hash['source'] = CGI.unescape(@hash['source'])
  end
end