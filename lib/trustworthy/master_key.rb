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
      nonce = Trustworthy::Cipher.generate_nonce
      nonce + _cipher.encrypt(nonce, '', plaintext)
    end

    def decrypt(ciphertext)
      ciphertext.force_encoding('BINARY') if ciphertext.respond_to?(:force_encoding)
      nonce = ciphertext.slice(0, Trustworthy::Cipher.nonce_len)
      ciphertext = ciphertext.slice(Trustworthy::Cipher.nonce_len..-1)
      _cipher.decrypt(nonce, '', ciphertext)
    end

    def _cipher
      secret = @intercept.to_s('F')
      hkdf = HKDF.new(secret)
      key = hkdf.next_bytes(Trustworthy::Cipher.key_len)
      Trustworthy::Cipher.new(key)
    end
  end
end
