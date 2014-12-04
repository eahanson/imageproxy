require 'gibberish'
require 'base64'
require 'uri'

module Imageproxy
  class Encryption

    def initialize app
      @app = app
    end

    def call env
      transform env if request_uri(env) =~ /^\/[^\/\?]+$/
      @app.call(env)
    end

    private

      def transform env
        path = request_uri env
        uri = URI( env['rack.url_scheme'] + '://' + env['HTTP_HOST'] + decrypt_path(path) )
        env['PATH_INFO'] = uri.path
        env['QUERY_STRING'] = uri.query
      end

      def secret
        ::Digest::SHA1.hexdigest ENV['IMAGEPROXY_SECRET']
      end

      def cipher
        @cipher ||= ::Gibberish::AES.new secret
      end

      def decrypt_path data
        begin
          data = data[1,data.size]
          cipher.dec ::Base64.decode64(data.tr("-_.", "+/\n")).strip
        rescue StandardError => e
          ""
        end
      end

      def encrypt_path data
        ::Base64.encode64(cipher.enc(data)).tr("+/\n", "-_.")
      end

      # not defined in rack spec, rack/test doesnt support this
      def request_uri env
        env['PATH_INFO'] + (env['QUERY_STRING'].empty? ? '' : '?' + env['QUERY_STRING'])
      end
  end
end