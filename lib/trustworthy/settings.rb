module Trustworthy
  class Settings
    attr_reader :keys, :secrets

    def self.load(filename)
      data = File.read(filename)
      yaml = YAML.load(data)
      new(yaml['keys'], yaml['secrets'])
    end

    def initialize(keys = {}, secrets = {})
      @keys = keys
      @secrets = secrets
    end

    def add_key(key, username, password)
      salt = SCrypt::Engine.generate_salt

      crypto = _crypto_from_password(salt, password)
      plaintext = "#{key.x.to_s('F')},#{key.y.to_s('F')}"
      ciphertext = crypto.encrypt(plaintext)

      @keys[username] = {
        'salt' => salt,
        'ciphertext' => ciphertext,
        'authentication' => crypto.sign(ciphertext)
      }
    end

    def add_secret(environment, filename)
      @secrets[environment] = filename
    end

    def unlock_key(username, password)
      key_data = keys[username]
      ciphertext = key_data['ciphertext']
      signature = key_data['authentication']
      salt = key_data['salt']
      crypto = _crypto_from_password(salt, password)
      raise 'invalid signature' unless crypto.valid_signature?(signature, ciphertext)
      plaintext = crypto.decrypt(ciphertext)
      x, y = plaintext.split(',').map { |n| BigDecimal.new(n) }
      Trustworthy::Key.new(x, y)
    end

    def write(filename)
      File.open(filename, 'w') do |file|
        data = YAML.dump('keys' => @keys, 'secrets' => @secrets)
        file.write(data)
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
