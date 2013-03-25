require 'spec_helper'

describe Trustworthy::Settings do
  before(:each) do
    SCrypt::Engine.stub(:generate_salt).and_return(TestValues::Salt)
    AEAD::Cipher::AES_256_CBC_HMAC_SHA_256.stub(:generate_nonce).and_return(TestValues::InitializationVector)
  end

  around(:each) do |example|
    within_construct do |construct|
      construct.file(TestValues::SettingsFile)
      example.run
    end
  end

  describe 'self.open' do
    it 'should read and write the key information to a file' do
      Trustworthy::Settings.open(TestValues::SettingsFile) do |settings|
        key = Trustworthy::Key.new(BigDecimal.new('2'), BigDecimal.new('3'))
        settings.add_key(key, 'user', 'password1')
      end

      Trustworthy::Settings.open(TestValues::SettingsFile) do |settings|
        found_key = settings.find_key('user')
        found_key['salt'].should == TestValues::Salt
        found_key['encrypted_point'].should == TestValues::EncryptedPoint
      end
    end

    it 'should preserve the contents if an exception is raised' do
      Trustworthy::Settings.open(TestValues::SettingsFile) do |settings|
        key = Trustworthy::Key.new(BigDecimal.new('2'), BigDecimal.new('3'))
        settings.add_key(key, 'user', 'password1')
      end

      expect do
        Trustworthy::Settings.open(TestValues::SettingsFile) do |settings|
          key = Trustworthy::Key.new(BigDecimal.new('2'), BigDecimal.new('3'))
          settings.add_key(key, 'user', 'password2')
          settings.add_key(key, 'missing', 'password')
          raise 'boom'
        end
      end.to raise_error

      Trustworthy::Settings.open(TestValues::SettingsFile) do |settings|
        settings.find_key('missing').should be_nil
        found_key = settings.find_key('user')
        found_key['salt'].should == TestValues::Salt
        found_key['encrypted_point'].should == TestValues::EncryptedPoint
      end
    end
  end

  describe 'add_key' do
    it 'should encrypt the key with the password' do |settings|
      Trustworthy::Settings.open(TestValues::SettingsFile) do |settings|
        key = Trustworthy::Key.new(BigDecimal.new('2'), BigDecimal.new('3'))
        settings.add_key(key, 'user', 'password1')
        found_key = settings.find_key('user')
        found_key['salt'].should == TestValues::Salt
        found_key['encrypted_point'].should == TestValues::EncryptedPoint
      end
    end
  end

  describe 'unlock_key' do
    it 'should decrypt the key with the password' do
      Trustworthy::Settings.open(TestValues::SettingsFile) do |settings|
        key = Trustworthy::Key.new(BigDecimal.new('2'), BigDecimal.new('3'))
        settings.add_key(key, 'user', 'password1')
        unlocked_key = settings.unlock_key('user', 'password1')
        unlocked_key.x.should == BigDecimal.new('2')
        unlocked_key.y.should == BigDecimal.new('3')
      end
    end
  end
end
