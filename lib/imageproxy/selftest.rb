module Imageproxy
  class Selftest
    def self.html(request, signature_required, signature_secret)
      html = <<-HTML
      <html>
        <head>
          <title>imageproxy selftest</title>
          <style type="text/css">
            body { background: url(/background.png); font-family: "Helvetica", sans-serif; font-size: smaller; }
            h3 { margin: 2em 0 0 0; }
            img { display: block; border: 1px solid black; margin: 1em 0; }
            .footer { margin-top: 2em; border-top: 1px solid #999; padding-top: 0.5em; font-size: smallest; }
          </style>
        </head>
        <body>
      HTML

      url_prefix = "#{request.scheme}://#{request.host_with_port}"
      raw_source = "http://eahanson.s3.amazonaws.com/imageproxy/sample.png"
      source = CGI.escape(URI.escape(URI.escape(raw_source)))

      raw_overlay = "http://www.imagemagick.org/image/smile.gif"
      overlay = CGI.escape(URI.escape(URI.escape(raw_overlay)))

      html += <<-HTML
      <h3>Original Image</h3>
      <a href="#{raw_source}">#{raw_source}</a>
      <img src="#{raw_source}">
      HTML

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

        ["Combo", "/convert?resize=100x100&shape=cut&rotate=45&background=%23ff00ff&source=#{source}"],

        ["Compositing", "/convert?source=#{source}&overlay=#{overlay}"],
        ["Composite and then do something else", "/convert?source=#{source}&overlay=#{overlay}&rotate=50"]
      ]

      examples.each do |example|
        path = example[1]
        if (signature_required)
          signature = CGI.escape(Signature.create(path, signature_secret))
          if path.include?("&")
            path += "&signature=#{signature}"
          else
            path += "/signature/#{signature}"
          end
        end
        example_url = url_prefix + path
        html += <<-HTML
        <h3>#{example[0]}</h3>
        <a href="#{example_url}">#{example_url}</a>
        <img src="#{example_url}">
        HTML
      end

      html += <<-HTML
          <div class="footer"><a href="https://github.com/eahanson/imageproxy">imageproxy</a> selftest</div>
        </body>
      </html>
      HTML

      html
    end
  end
end