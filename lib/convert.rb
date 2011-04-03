class Convert < Command
  def initialize(options)
    @options = options
  end

  def execute
    execute_command %'curl -s "#{@options.source}" | convert - -resize #{@options.resize} #{file.path}'
    file
  end

  def file
    @tempfile ||= Tempfile.new("imageproxy").tap(&:close)
  end
end