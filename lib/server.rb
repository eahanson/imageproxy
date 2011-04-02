class Server
  def call(env)
    options = Options.new(env["PATH_INFO"])
    file = Convert.new(options).execute

    class << file
      alias to_path path
    end

    file.open
    [200, {"Content-Type" => options.output_mime_type}, file]
  rescue NotFound
    [404, {"Content-Type" => "text/plain"}, "Not found"]
  rescue
    [500, {"Content-Type" => "text/plain"}, "Sorry, an internal error occurred"]
  end
end