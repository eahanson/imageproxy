require File.join(File.expand_path(File.dirname(__FILE__)), "options")
require File.join(File.expand_path(File.dirname(__FILE__)), "convert")
require File.join(File.expand_path(File.dirname(__FILE__)), "identify")

class Server
  def call(env)
    request = Rack::Request.new(env)
    options = Options.new(request.path_info, request.params)
    user_agent = request.env["HTTP_USER_AGENT"]

    case options.command
      when "convert", "process"
        file = Convert.new(options).execute(user_agent)
        class << file
          alias to_path path
        end

        file.open
        [200, {"Content-Type" => options.content_type}, file]
      when "identify"
        [200, {"Content-Type" => "text/plain"}, Identify.new(options).execute(user_agent)]
      else
        [404, {"Content-Type" => "text/plain"}, "Not found"]
    end
  rescue
    STDERR.puts $!
    [500, {"Content-Type" => "text/plain"}, "Sorry, an internal error occurred"]
  end
end
