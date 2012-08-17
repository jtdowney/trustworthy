module Trustworthy
  class Crypto
    def initialize(encryption_key, authentication_key)
      @encryption_key = encryption_key
      @authentication_key = authentication_key
      @digest = OpenSSL::Digest.new('SHA256')
      @cipher = OpenSSL::Cipher.new('AES-256-CBC')
    end

    def decrypt(ciphertext)
      ciphertext.force_encoding('BINARY') if ciphertext.respond_to?(:force_encoding)
      iv = ciphertext.slice(0..15)
      ciphertext = ciphertext.slice(16..-1)
      @cipher.decrypt
      @cipher.key = @encryption_key
      @cipher.iv = iv
      @cipher.update(ciphertext) + @cipher.final
    end

    def encrypt(plaintext)
      iv = Trustworthy::Random.bytes(16)
      @cipher.encrypt
      @cipher.key = @encryption_key
      @cipher.iv = iv
      ciphertext = @cipher.update(plaintext) + @cipher.final
      iv + ciphertext
    end

    def sign(data)
      OpenSSL::HMAC.digest(@digest, @authentication_key, data)
    end

    def valid_signature?(given_signature, data)
      computed_signature = sign(data)
      _secure_compare(given_signature, computed_signature)
    end

    def _secure_compare(a, b)
      return false unless a.bytesize == b.bytesize

      bytes = a.unpack("C#{a.bytesize}")

      result = 0
      b.each_byte do |byte|
        result |= byte ^ bytes.shift
      end
      result == 0
    end
  end
end
