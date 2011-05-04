require 'bundler'
Bundler.require :test

desc "Run all specs"
task :spec do
  system 'rspec --format nested --color spec'
end

task :default => :spec

desc "Run the server locally (for development)"
task :run do
  require 'uri'
  puts <<EOF

See examples at:

  http://localhost:9393/selftest

EOF
  system 'shotgun'
end
