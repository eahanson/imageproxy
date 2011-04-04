require 'bundler'
Bundler.require :test

desc "Run all specs"
task :spec do
  system 'rspec --format nested --color spec'
end

task :default => :spec

desc "Run the server locally (for development)"
task :run do
  require 'cgi'
  puts <<EOF

Examples:

http://localhost:9393/convert/resize/100x100/source/#{CGI.escape(CGI.escape("http://www.google.com/images/logos/ps_logo2.png"))}
http://localhost:9393/identify/source/#{CGI.escape(CGI.escape("http://www.google.com/images/logos/ps_logo2.png"))}

EOF
  system 'shotgun'
end
