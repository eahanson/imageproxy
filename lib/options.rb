class Options
  def initialize(query_string)
    params = query_string.split('/').reject { |s| s.nil? || s.empty? }
    @hash = Hash[*params]

    unescape_source
  end

  def [](key)
    @hash[key.to_s]
  end

  def []=(key, value)
    @hash[key.to_s] = value
  end
  
  def unescape_source
    return unless self[:source]
    self[:source] = CGI.unescape(self[:source])
  end
end