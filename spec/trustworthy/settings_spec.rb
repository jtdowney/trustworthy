require 'spec_helper'

describe Trustworthy::Settings do
  before(:each) do
    allow(AEAD::Cipher::AES_256_CBC_HMAC_SHA_256).to receive(:generate_nonce).and_return(TestValues::InitializationVector)
  end

  around(:each) do |example|
    within_construct do |construct|
      construct.file(TestValues::SettingsFile)
      example.run
    end
  end

  describe 'self.open' do
    it 'should read and write the key information to a file' do
      Timecop.freeze(DateTime.new(2017, 10, 19, 9, 0, 0, 0)) do
        Trustworthy::Settings.open(TestValues::SettingsFile) do |settings|
          key = Trustworthy::Key.new(BigDecimal('2'), BigDecimal('3'))
          settings.add_key(key, 'user', 'password1')
        end

        Trustworthy::Settings.open(TestValues::SettingsFile) do |settings|
          found_key = settings.find_key('user')
          timestamp = DateTime.parse(found_key['timestamp'])
          expect(found_key['salt']).to eq(TestValues::Salt)
          expect(found_key['encrypted_point']).to eq(TestValues::EncryptedPoint)
          expect(timestamp).to eq(DateTime.new(2017, 10, 19, 9, 0, 0, 0))
        end
      end
    end

    it 'should preserve the contents if an exception is raised' do
      Trustworthy::Settings.open(TestValues::SettingsFile) do |settings|
        key = Trustworthy::Key.new(BigDecimal('2'), BigDecimal('3'))
        settings.add_key(key, 'user', 'password1')
      end

      expect do
        Trustworthy::Settings.open(TestValues::SettingsFile) do |settings|
          key = Trustworthy::Key.new(BigDecimal('2'), BigDecimal('3'))
          settings.add_key(key, 'user', 'password2')
          settings.add_key(key, 'missing', 'password')
          raise 'boom'
        end
      end.to raise_error(RuntimeError)

      Trustworthy::Settings.open(TestValues::SettingsFile) do |settings|
        missing_key = settings.find_key('missing')
        expect(missing_key).to be_nil

        found_key = settings.find_key('user')
        expect(found_key['salt']).to eq(TestValues::Salt)
        expect(found_key['encrypted_point']).to eq(TestValues::EncryptedPoint)
      end
    end
  end

  describe 'add_key' do
    it 'should encrypt the key with the password' do
      Trustworthy::Settings.open(TestValues::SettingsFile) do |settings|
        key = Trustworthy::Key.new(BigDecimal('2'), BigDecimal('3'))
        settings.add_key(key, 'user', 'password1')
        found_key = settings.find_key('user')
        expect(found_key['salt']).to eq(TestValues::Salt)
        expect(found_key['encrypted_point']).to eq(TestValues::EncryptedPoint)
      end
    end
  end

  describe 'has_key?' do
    it 'should be true if the key exists' do
      Trustworthy::Settings.open(TestValues::SettingsFile) do |settings|
        key = Trustworthy::Key.new(BigDecimal('2'), BigDecimal('3'))
        settings.add_key(key, 'user', 'password1')
        expect(settings.key?('user')).to be_truthy
      end
    end

    it 'should be false if the key does exists' do
      Trustworthy::Settings.open(TestValues::SettingsFile) do |settings|
        expect(settings.key?('missing')).to_not be_truthy
      end
    end
  end

  describe 'recoverable?' do
    it 'should not be recoverable with no user keys' do
      Trustworthy::Settings.open(TestValues::SettingsFile) do |settings|
        expect(settings).to_not be_recoverable
      end
    end

    it 'should not be recoverable with one user key' do
      Trustworthy::Settings.open(TestValues::SettingsFile) do |settings|
        key = Trustworthy::Key.new(BigDecimal('2'), BigDecimal('3'))
        settings.add_key(key, 'user', 'password')
        expect(settings).to_not be_recoverable
      end
    end

    it 'should be recoverable with two or more user keys' do
      Trustworthy::Settings.open(TestValues::SettingsFile) do |settings|
        key1 = Trustworthy::Key.new(BigDecimal('2'), BigDecimal('3'))
        key2 = Trustworthy::Key.new(BigDecimal('3'), BigDecimal('4'))
        settings.add_key(key1, 'user1', 'password')
        settings.add_key(key2, 'user2', 'password')
        expect(settings).to be_recoverable
      end
    end
  end

  describe 'unlock_key' do
    it 'should decrypt the key with the password' do
      Trustworthy::Settings.open(TestValues::SettingsFile) do |settings|
        key = Trustworthy::Key.new(BigDecimal('2'), BigDecimal('3'))
        settings.add_key(key, 'user', 'password1')
        unlocked_key = settings.unlock_key('user', 'password1')
        expect(unlocked_key.x).to eq(BigDecimal('2'))
        expect(unlocked_key.y).to eq(BigDecimal('3'))
      end
    end
  end
end
