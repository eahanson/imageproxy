require 'tempfile'
require 'pp'

class Server
  def call(env)
    path = env["PATH_INFO"]
    command = Command.new(Options.new(path))
#    file = File.open(command.execute.path)
    file = command.execute
    file.open
    class << file
      alias to_path path
    end
    [200, {"Content-Type" => "text/plain"}, file]
  end
end