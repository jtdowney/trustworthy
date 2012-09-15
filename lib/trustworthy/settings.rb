module Trustworthy
  class Settings
    attr_reader :keys, :secrets

    def initialize(filename)
      @store = YAML::Store.new(filename)
      @store.transaction do
        @keys = @store.fetch(:keys, {})
        @secrets = @store.fetch(:secrets, {})
      end
    end

    def add_key(key, username, password)
      salt = SCrypt::Engine.generate_salt

      crypto = _crypto_from_password(salt, password)
      plaintext = "#{key.x.to_s('F')},#{key.y.to_s('F')}"
      ciphertext = crypto.encrypt(plaintext)

      @keys[username] = {
        :salt => salt,
        :encrypted_point => ciphertext,
        :encrypted_point_signature => crypto.sign(ciphertext)
      }
    end

    def add_secret(environment, filename)
      @secrets[environment] = filename
    end

    def unlock_key(username, password)
      key_data = keys[username]
      ciphertext = key_data[:encrypted_point]
      signature = key_data[:encrypted_point_signature]
      salt = key_data[:salt]

      crypto = _crypto_from_password(salt, password)
      raise 'invalid signature' unless crypto.valid_signature?(signature, ciphertext)

      plaintext = crypto.decrypt(ciphertext)
      x, y = plaintext.split(',').map { |n| BigDecimal.new(n) }
      Trustworthy::Key.new(x, y)
    end

    def write(filename)
      @store.transaction do
        @store[:keys] = @keys
        @store[:secrets] = @secrets
      end
    end

    def _crypto_from_password(salt, password)
      cost, salt = salt.rpartition('$')
      raw_key = SCrypt::Engine.scrypt(password, salt, cost, 64)

      encryption_key = raw_key.slice(0, 32)
      authentication_key = raw_key.slice(32, 32)

      Trustworthy::Crypto.new(encryption_key, authentication_key)
    end
  end
end
