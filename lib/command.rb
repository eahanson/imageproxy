class Command
  def initialize(options)
    @options = options
  end

  def command
    %'curl -s "#{@options.source}" | convert - -resize 10x20 dest.jpg'
  end
end