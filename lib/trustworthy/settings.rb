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

      cipher = _cipher_from_password(salt, password)
      nonce = Trustworthy::Cipher.generate_nonce
      plaintext = "#{key.x.to_s('F')},#{key.y.to_s('F')}"
      ciphertext = cipher.encrypt(nonce, '', plaintext)

      @keys[username] = {
        :salt => salt,
        :encrypted_point => nonce + ciphertext,
      }
    end

    def add_secret(environment, filename)
      @secrets[environment] = filename
    end

    def unlock_key(username, password)
      key_data = keys[username]
      salt = key_data[:salt]
      ciphertext = key_data[:encrypted_point]
      ciphertext.force_encoding('BINARY') if ciphertext.respond_to?(:force_encoding)
      nonce = ciphertext.slice(0, Trustworthy::Cipher.nonce_len)
      ciphertext = ciphertext.slice(Trustworthy::Cipher.nonce_len..-1)

      cipher = _cipher_from_password(salt, password)
      plaintext = cipher.decrypt(nonce, '', ciphertext)
      x, y = plaintext.split(',').map { |n| BigDecimal.new(n) }
      Trustworthy::Key.new(x, y)
    end

    def write(filename)
      @store.transaction do
        @store[:keys] = @keys
        @store[:secrets] = @secrets
      end
    end

    def _cipher_from_password(salt, password)
      cost, salt = salt.rpartition('$')
      key = SCrypt::Engine.scrypt(password, salt, cost, 64)
      Trustworthy::Cipher.new(key)
    end
  end
end
