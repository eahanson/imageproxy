require 'rake'
require 'rspec/core/rake_task'

task :default => :spec

task :spec do
  system 'rspec --format nested --color spec'
end

task :run do
  puts
  puts "http://localhost:9393/"
  puts
  system 'shotgun'
end
