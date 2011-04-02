class Server
  def call(env)
    file = Convert.new(Options.new(env["PATH_INFO"])).execute

    class << file
      alias to_path path
    end

    file.open
    [200, {"Content-Type" => "text/plain"}, file]
  end
end