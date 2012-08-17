module Trustworthy
  class MasterKey
    def self.create
      slope = Trustworthy::Random.number
      intercept = Trustworthy::Random.number
      new(slope, intercept)
    end

    def self.create_from_keys(key1, key2)
      slope = (key2.y - key1.y) / (key2.x - key1.x)
      intercept = key1.y - (slope * key1.x)
      new(slope, intercept)
    end

    def initialize(slope, intercept)
      @slope = slope
      @intercept = intercept
    end

    def create_key
      Trustworthy::Key.create(@slope, @intercept)
    end

    def encrypt(plaintext)
      ciphertext = _crypto.encrypt(plaintext)
      signature = _crypto.sign(ciphertext)
      signature + ciphertext
    end

    def decrypt(ciphertext)
      ciphertext.force_encoding('BINARY') if ciphertext.respond_to?(:force_encoding)
      signature = ciphertext.slice(0..31)
      ciphertext = ciphertext.slice(32..-1)
      raise 'invalid signature' unless _crypto.valid_signature?(signature, ciphertext)
      _crypto.decrypt(ciphertext)
    end

    def _crypto
      return @crypto if @crypto

      secret = @intercept.to_s('F')
      hkdf = HKDF.new(secret)
      encryption_key = hkdf.next_bytes(32)
      authentication_key = hkdf.next_bytes(32)
      @crypto = Trustworthy::Crypto.new(encryption_key, authentication_key)
    end
  end
end
