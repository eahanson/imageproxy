class Command
  def initialize(options)
    @options = options
  end

  def execute
    cmd = %'curl -s "#{@options.source}" | convert - -resize 10x20 #{file.path}'
    system cmd
    file
  end

  def file
    @tempfile ||= Tempfile.new("imageproxy").tap(&:close)
  end
end