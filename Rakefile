require 'bundler'
Bundler.require :test

desc "Run all specs"
task :spec do
  system 'rspec --format nested --color spec'
end

task :default => :spec

desc "Run the server"
task :run do
  puts
  puts "http://localhost:9393/"
  puts
  system 'shotgun'
end
