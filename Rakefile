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

If you set IMAGEPROXY_SIGNATURE_REQUIRED and IMAGEPROXY_SIGNATURE_SECRET
environment variables, then the requests in the selftest will be
signed.

EOF
  system 'shotgun'
end


require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "imageproxy"
  gem.homepage = "http://github.com/eahanson/imageproxy"
  gem.license = "MIT"
  gem.summary = %Q{A image processing proxy server, written in Ruby as a Rack application.}
  gem.description = %Q{A image processing proxy server, written in Ruby as a Rack application. Requires ImageMagick.}
  gem.email = "erik@eahanson.com"
  gem.authors = ["Erik Hanson"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

