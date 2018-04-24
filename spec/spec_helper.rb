require 'trustworthy'
require 'trustworthy/cli'
require 'test_construct'
require 'timecop'
require 'highline/simulate'

module TestValues
  SettingsFile = 'trustworthy.yml'.freeze
  InitializationVector = ['39164ec082fb8b7336d3c5500af99dcb'].pack('H*')
  Plaintext = 'the chair is against the wall'.freeze
  Ciphertext = 'ORZOwIL7i3M208VQCvmdyw==--b16sXYF6ZbisfF7YBpHbNpBOHOYToQV9gHs3En2SeksKmhuVHvV2/Jqe3KDvW4PiuuhQqLO3m/7d/4ktGUHUOQ=='.freeze
  Salt = '400$8$1b$3e31f076a3226825'.freeze
  MasterKey = Trustworthy::MasterKey.new(BigDecimal('1'), BigDecimal('5'))
  EncryptedPoint = 'ORZOwIL7i3M208VQCvmdyw==--F9LmBJbtVT36tLBcVoqpJgy45TkwkRyOcYvJfriN70AOXKweTuPRUGCSDCXRNGKF'.freeze
  # rubocop:disable Layout/IndentHeredoc
  EncryptedFile = <<-FILE.freeze
-----BEGIN TRUSTWORTHY ENCRYPTED FILE-----
Version: Trustworthy/#{Trustworthy::VERSION}

ORZOwIL7i3M208VQCvmdyw==--o39ZYHOC+HotoUiBqeHqvSOWXUbXwaZRsMkwzQ
7nVtk1jWftqroCoi6QITaiqQlTZywpN7DLqsAWeSKRhXipjA==
-----END TRUSTWORTHY ENCRYPTED FILE-----
FILE
  # rubocop:enable Layout/IndentHeredoc
end

SCrypt::Engine::DEFAULTS[:cost] = '400$8$1b$'

RSpec.configure do |config|
  config.order = 'random'
  config.include TestConstruct::Helpers
  config.before(:each) do
    allow(SCrypt::Engine).to receive(:generate_salt).and_return(TestValues::Salt)
  end
end

def create_config(filename)
  Trustworthy::Settings.open(filename) do |settings|
    settings.add_key(TestValues::MasterKey.create_key, 'user1', 'P@ssw0rd1')
    settings.add_key(TestValues::MasterKey.create_key, 'user2', 'P@ssw0rd2')
  end
end
