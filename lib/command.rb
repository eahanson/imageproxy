class Command
  protected

  def execute_command(command_line)
    stdin, stdout, stderr = Open3.popen3(command_line)
    [output_to_string(stdout), output_to_string(stderr)].join("")
  end

  def to_path(obj)
    obj.respond_to?(:path) ? obj.path : obj.to_s
  end

  def output_to_string(output)
    output.readlines.join("").chomp
  end

end