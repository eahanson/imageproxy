module Imageproxy
  class Command
    protected

    def execute_command(command_line)
      stdin, stdout, stderr = Open3.popen3(command_line)
      [output_to_string(stdout), output_to_string(stderr)].join("")
    end

    def curl(url, options={})
      user_agent = options[:user_agent] || "imageproxy"
      %|curl -L -s -A "#{user_agent}" "#{url}"|
    end

    def to_path(obj)
      obj.respond_to?(:path) ? obj.path : obj.to_s
    end

    def output_to_string(output)
      output.readlines.join("").chomp
    end
  end
end