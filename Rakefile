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
  source = URI.escape(URI.escape("http://www.google.com/images/logos/ps_logo2.png"))
  puts <<EOF

Examples:
  CloudFront-compatible URLs:
    http://localhost:9393/convert/resize/100x100/source/#{source}
    http://localhost:9393/identify/source/#{source}

  Regular query string URLs:
    http://localhost:9393/convert?resize=100x100&source=#{source}
    http://localhost:9393/identify?source=#{source}

  Resize:
    http://localhost:9393/convert?resize=100x100&source=#{source}

  Resize with padding:
    http://localhost:9393/convert?resize=100x100&shape=pad&source=#{source}
    http://localhost:9393/convert?resize=100x100&shape=pad&background=%23ff00ff&source=#{source}

  Resize with cutting:
    http://localhost:9393/convert?resize=100x100&shape=cut&source=#{source}

  Flipping:
    http://localhost:9393/convert?flip=horizontal&source=#{source}
    http://localhost:9393/convert?flip=vertical&source=#{source}

  Rotating:
    http://localhost:9393/convert?rotate=90&source=#{source}
    http://localhost:9393/convert?rotate=120&source=#{source}
    http://localhost:9393/convert?rotate=120&background=%23ff00ff&source=#{source}

  Combo:
    http://localhost:9393/convert?resize=100x100&shape=cut&rotate=45&background=%23ff00ff&source=#{source}

EOF
  system 'shotgun'
end
