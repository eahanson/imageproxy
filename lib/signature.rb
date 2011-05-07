require 'base64'
require 'openssl'

class Signature
  def self.create(path, secret)
    Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'), secret, remove_signature_from(path))).strip.tr('+/', '-_')
  end

  def self.remove_signature_from(path)
    #TODO: do this in fewer passes
    path.
      sub(%r{&signature(=[^&]*)?(?=&|$)}, "").
      sub(%r{\?signature(=[^&]*)?&}, "?").
      sub(%r{\?signature(=[^&]*)?$}, "").
      sub(%r{/signature/[^\?/]+/}, "/").
      sub(%r{/signature/[^\?/]+\?}, "?").
      sub(%r{/signature/[^\?/]+}, "")
  end

  def self.correct?(signature, path, secret)
    signature != nil && path != nil && secret != nil && create(path, secret) == signature
  end
end