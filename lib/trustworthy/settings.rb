module Trustworthy
  class Settings
    def self.open(filename)
      store = YAML::Store.new(filename)
      store.ultra_safe = true if store.respond_to?(:ultra_safe=)

      store.transaction do
        yield Trustworthy::Settings.new(store)
      end
    end

    def initialize(store)
      @store = store
    end

    def add_key(key, username, password)
      salt = SCrypt::Engine.generate_salt
      plaintext = "#{key.x.to_s('F')},#{key.y.to_s('F')}"
      encrypted_point = _encrypt(plaintext, salt, password)
      @store[username] = {'salt' => salt, 'encrypted_point' => encrypted_point}
    end

    def empty?
      @store.roots.empty?
    end

    def find_key(username)
      @store[username]
    end

    def has_key?(username)
      @store.root?(username)
    end

    def recoverable?
      @store.roots.count >= 2
    end

    def unlock_key(username, password)
      key = find_key(username)
      salt = key['salt']
      ciphertext = key['encrypted_point']
      plaintext = _decrypt(ciphertext, salt, password)
      x, y = plaintext.split(',').map { |n| BigDecimal.new(n) }
      Trustworthy::Key.new(x, y)
    end

    def _cipher_from_password(salt, password)
      cost, salt = salt.rpartition('$')
      key = SCrypt::Engine.scrypt(password, salt, cost, Trustworthy::Cipher.key_len)
      Trustworthy::Cipher.new(key)
    end

    def _decrypt(ciphertext, salt, password)
      cipher = _cipher_from_password(salt, password)
      nonce, ciphertext = ciphertext.split('--').map do |field|
        Base64.decode64(field)
      end
      cipher.decrypt(nonce, '', ciphertext)
    end

    def _encrypt(plaintext, salt, password)
      cipher = _cipher_from_password(salt, password)
      nonce = Trustworthy::Cipher.generate_nonce
      ciphertext = cipher.encrypt(nonce, '', plaintext)
      [nonce, ciphertext].map do |field|
        Base64.encode64(field).gsub("\n", '')
      end.join('--')
    end
  end
end
