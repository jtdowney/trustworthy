require 'trustworthy'
require 'trustworthy/cli'
require 'construct'
require 'highline/simulate'

RSpec.configure do |config|
  config.order = 'random'
  config.include Construct::Helpers
  config.before(:each) do
    Trustworthy::Random.stub(:_source).and_return('/dev/urandom')
  end
end

module TestValues
  SettingsFile = 'trustworthy.yml'
  InitializationVector = ['39164ec082fb8b7336d3c5500af99dcb'].pack('H*')
  Plaintext = 'the chair is against the wall'
  Ciphertext = ['39164ec082fb8b7336d3c5500af99dcb6f5eac5d817a65b8ac7c5ed80691db36904e1ce613a1057d807b37127d927a4b0a9a1b951ef576fc9a9edca0ef5b83e2bae850a8b3b79bfeddff892d1941d439'].pack('H*')
  Salt = '400$8$1b$3e31f076a3226825'
  MasterKey = Trustworthy::MasterKey.new(BigDecimal.new('1'), BigDecimal.new('5'))
  EncryptedPoint = 'ORZOwIL7i3M208VQCvmdyw==--F9LmBJbtVT36tLBcVoqpJgy45TkwkRyOcYvJfriN70AOXKweTuPRUGCSDCXRNGKF'
  EncryptedFile = ['39164ec082fb8b7336d3c5500af99dcba37f59607382f87a2da14881a9e1eabd23965d46d7c1a651b0c930cd0ee756d9358d67edaaba02a22e902136a2a90953672c2937b0cbaac0167922918578a98c'].pack('H*')
end

def create_config(filename)
  Trustworthy::Settings.open(filename) do |settings|
    settings.add_key(TestValues::MasterKey.create_key, 'user1', 'password1')
    settings.add_key(TestValues::MasterKey.create_key, 'user2', 'password2')
  end
end
