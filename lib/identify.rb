require File.join(File.expand_path(File.dirname(__FILE__)), "command")

class Identify < Command
  def initialize(options)
    @options = options
  end

  def execute
    execute_command %'curl -s "#{@options.source}" | identify -verbose -'
  end
end