app = proc do |env|
   [ 200, {'Content-Type' => 'text/plain'}, "imageproxy" ]
end

run app