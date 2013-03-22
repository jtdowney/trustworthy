require 'spec_helper'

describe Trustworthy::Settings do
  SettingsFile = 'test.yml'

  let(:settings) { Trustworthy::Settings.new(SettingsFile) }

  before(:each) do
    SCrypt::Engine.stub(:generate_salt).and_return('400$8$1b$3e31f076a3226825')
    AEAD::Cipher::AES_256_CBC_HMAC_SHA_256.stub(:generate_nonce).and_return(TestValues::InitializationVector)
  end

  around(:each) do |example|
    within_construct do |construct|
      construct.file(SettingsFile)
      example.run
    end
  end

  describe 'add_key' do
    it 'encrypts and signs the key with the password' do
      key = Trustworthy::Key.new(BigDecimal.new('2'), BigDecimal.new('3'))
      settings.add_key(key, 'user', 'password1')
      settings.keys['user'][:salt].should == '400$8$1b$3e31f076a3226825'
      settings.keys['user'][:encrypted_point].should == TestValues::EncryptedPoint
    end
  end

  describe 'add_secret' do
    it 'adds a secret file name with an environment' do
      settings.add_secret('foo', 'foo.enc')
      settings.secrets['foo'].should == 'foo.enc'
    end
  end

  describe 'unlock_key' do
    it 'verifies and decrypts the key with the password' do
      key = Trustworthy::Key.new(BigDecimal.new('2'), BigDecimal.new('3'))
      settings.add_key(key, 'user', 'password1')
      unlocked_key = settings.unlock_key('user', 'password1')
      unlocked_key.x.should == BigDecimal.new('2')
      unlocked_key.y.should == BigDecimal.new('3')
    end
  end

  describe 'write' do
    it 'writes key information to the given file' do
      key = Trustworthy::Key.new(BigDecimal.new('2'), BigDecimal.new('3'))
      settings.add_key(key, 'user', 'password1')

      settings.write('settings.yml')

      store = YAML::Store.new(SettingsFile)
      store.transaction do
        store[:keys]['user'][:salt].should == '400$8$1b$3e31f076a3226825'
        store[:keys]['user'][:encrypted_point].should == TestValues::EncryptedPoint
      end
    end
  end

  describe 'self.load' do
    it 'loads the key information from the given file' do
      store = YAML::Store.new(SettingsFile)
      store.transaction do
        store[:keys] = {
          'user' => {
            :salt => '400$8$1b$3e31f076a3226825',
            :encrypted_point => ['17d2e60496ed553dfab4b05c568aa9260cb8e53930911c8e718bc97eb88def400e5cac1e4ee3d15060920c25d1346285'].pack('H*')
          }
        }
      end

      settings = Trustworthy::Settings.new(SettingsFile)
      settings.keys['user'][:salt].should == '400$8$1b$3e31f076a3226825'
      settings.keys['user'][:encrypted_point].should == ['17d2e60496ed553dfab4b05c568aa9260cb8e53930911c8e718bc97eb88def400e5cac1e4ee3d15060920c25d1346285'].pack('H*')
    end
  end
end
