module Trustworthy
  class MasterKey
    attr_reader :slope, :intercept

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

    def ==(other)
      @slope == other.slope && @intercept == other.intercept
    end

    def create_key
      Trustworthy::Key.create(@slope, @intercept)
    end

    def encrypt(plaintext)
      nonce = Trustworthy::Cipher.generate_nonce
      ciphertext = _cipher.encrypt(nonce, '', plaintext)

      [nonce, ciphertext].map do |field|
        Base64.strict_encode64(field)
      end.join('--')
    end

    def decrypt(ciphertext)
      nonce, ciphertext = ciphertext.split('--').map do |field|
        Base64.decode64(field)
      end

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
