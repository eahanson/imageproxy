require 'rake'
require 'rspec/core/rake_task'

task :default => :spec

desc "Run all specs"
task :spec do
  system 'rspec --format nested --color spec'
end

desc "Run the server"
task :run do
  puts
  puts "http://localhost:9393/"
  puts
  system 'shotgun'
end
