class Compare
  def initialize(a, b)
    @path_a = to_path(a)
    @path_b = to_path(b)
  end

  def execute
    output_file = Tempfile.new("compare")
    compare_command = %'compare -metric AE "#{@path_a}" "#{@path_b}" "#{output_file.path}"'
    stdin, stdout, stderr = Open3.popen3(compare_command)
    [output_to_string(stdout), output_to_string(stderr)].join("")
  end

  private

  def to_path(obj)
    obj.respond_to?(:path) ? obj.path : obj.to_s
  end

  def output_to_string(output)
    output.readlines.join("").chomp
  end
end