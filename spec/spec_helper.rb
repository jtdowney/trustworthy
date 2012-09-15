require 'trustworthy'

RSpec.configure do |config|
  config.order = 'random'
  config.before(:each) do
    Trustworthy::Random.stub(:_source).and_return('/dev/urandom')
  end
end

module Trustworthy
  module TestValues
    EncryptionKey = ['7fc6880ba7a75148e6b14a6ebca73b9861954835fd17237cbedb71a6ad3fefc4'].pack('H*')
    AuthenticationKey = ['12e7489dc1b2e6da1213cac0df946615a7088eeccdd6b2d4bf330e9560fabd52'].pack('H*')
    InitializationVector = ['39164ec082fb8b7336d3c5500af99dcb'].pack('H*')
  end
end
