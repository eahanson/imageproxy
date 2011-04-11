class Server
  def call(env)
    request = Rack::Request.new(env)
    options = Options.new(request.path_info, request.params)

    case options.command
      when "convert", "process"
        file = Convert.new(options).execute
        class << file
          alias to_path path
        end

        file.open
        [200, {"Content-Type" => options.content_type}, file]
      when "identify"
        [200, {"Content-Type" => "text/plain"}, Identify.new(options).execute]
      else
        [404, {"Content-Type" => "text/plain"}, "Not found"]
    end
  rescue
    STDERR.puts $!
    [500, {"Content-Type" => "text/plain"}, "Sorry, an internal error occurred"]
  end
end
