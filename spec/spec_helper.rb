require 'trustworthy'
require 'construct'

RSpec.configure do |config|
  config.order = 'random'
  config.include Construct::Helpers
  config.before(:each) do
    Trustworthy::Random.stub(:_source).and_return('/dev/urandom')
  end
end

module TestValues
  InitializationVector = ['39164ec082fb8b7336d3c5500af99dcb'].pack('H*')
  Plaintext = 'the chair is against the wall'
  Ciphertext = ['39164ec082fb8b7336d3c5500af99dcb6f5eac5d817a65b8ac7c5ed80691db36904e1ce613a1057d807b37127d927a4b0a9a1b951ef576fc9a9edca0ef5b83e2bae850a8b3b79bfeddff892d1941d439'].pack('H*')
  EncryptedPoint = ['39164ec082fb8b7336d3c5500af99dcb17d2e60496ed553dfab4b05c568aa9260cb8e53930911c8e718bc97eb88def400e5cac1e4ee3d15060920c25d1346285'].pack('H*')
end
