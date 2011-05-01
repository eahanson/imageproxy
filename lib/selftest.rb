class Selftest
  def self.html(request)
    html = <<-HTML
      <html>
        <head>
          <title>imageproxy selftest</title>
          <style type="text/css">
            body { font-family: monospace; background: url(/background.png); }
            h3 { margin: 2em 0 0 0; }
            img { display: block; border: 1px solid blue; }
          </style>
        </head>
        <body>
    HTML

    url_prefix = "#{request.scheme}://#{request.host_with_port}"
    source = CGI.escape(URI.escape(URI.escape(url_prefix + "/sample.png")))
    
    examples = [
      ["Resize (regular query-string URL format)", "/convert?resize=100x100&source=#{source}"],
      ["Resize (CloudFront-compatible URL format)", "/convert/resize/100x100/source/#{source}"],

      ["Resize with padding", "/convert?resize=100x100&shape=pad&source=#{source}"],
      ["Resize with padding & background color", "/convert?resize=100x100&shape=pad&background=%23ff00ff&source=#{source}"],

      ["Resize with cutting", "/convert?resize=100x100&shape=cut&source=#{source}"],

      ["Flipping horizontally", "/convert?flip=horizontal&source=#{source}"],
      ["Flipping vertically", "/convert?flip=vertical&source=#{source}"],

      ["Rotating to a 90-degree increment", "/convert?rotate=90&source=#{source}"],
      ["Rotating to a non-90-degree increment", "/convert?rotate=120&source=#{source}"],
      ["Rotating to a non-90-degree increment with a background color", "/convert?rotate=120&background=%23ff00ff&source=#{source}"],

      ["Combo", "/convert?resize=100x100&shape=cut&rotate=45&background=%23ff00ff&source=#{source}"]
    ]

    examples.each do |example|
      example_url = url_prefix + example[1]
      html += <<-HTML
        <h3>#{example[0]}</h3>
        <a href="#{example_url}">#{example_url}</a>
        <img src="#{example_url}">
      HTML
    end

    html += <<-HTML
        </body>
      </html>
    HTML

    html
  end
end