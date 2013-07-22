require 'spec_helper'

describe Trustworthy::MasterKey do
  it 'should encrypt and decrypt a master_key' do
    master_key = Trustworthy::MasterKey.create
    key1 = master_key.create_key
    key2 = master_key.create_key

    ciphertext = master_key.encrypt(TestValues::Plaintext)

    new_master_key = Trustworthy::MasterKey.create_from_keys(key1, key2)
    plaintext = new_master_key.decrypt(ciphertext)
    expect(plaintext).to eq(TestValues::Plaintext)
  end

  it 'should function with any 2 of n keys' do
    master_key1 = Trustworthy::MasterKey.create
    key1 = master_key1.create_key
    key2 = master_key1.create_key

    ciphertext = master_key1.encrypt(TestValues::Plaintext)

    master_key2 = Trustworthy::MasterKey.create_from_keys(key1, key2)
    key3 = master_key2.create_key

    master_key3 = Trustworthy::MasterKey.create_from_keys(key1, key3)
    plaintext = master_key3.decrypt(ciphertext)
    expect(plaintext).to eq(TestValues::Plaintext)
  end

  describe 'self.create' do
    it 'should generate a random slope and intercept' do
      Trustworthy::Random.stub(:number).and_return(BigDecimal.new('10'))
      master_key = Trustworthy::MasterKey.create
      key = master_key.create_key
      expect(key.x).to eq(10)
      expect(key.y).to eq(110)
    end
  end

  describe 'self.create_from_keys' do
    it 'should calculate the slope and intercept given two keys' do
      Trustworthy::Random.stub(:number).and_return(BigDecimal.new('10'))

      key1 = Trustworthy::Key.new(BigDecimal.new('2'), BigDecimal.new('30'))
      key2 = Trustworthy::Key.new(BigDecimal.new('5'), BigDecimal.new('60'))

      master_key = Trustworthy::MasterKey.create_from_keys(key1, key2)
      new_key = master_key.create_key
      expect(new_key.x).to eq(10)
      expect(new_key.y).to eq(110)
    end
  end

  describe 'create_key' do
    it 'should define a new key' do
      master_key = Trustworthy::MasterKey.new(BigDecimal.new('6'), BigDecimal.new('24'))
      key = master_key.create_key
      expect(key.x).to_not eq(0)
      expect(key.y).to_not eq(0)
    end
  end

  describe 'encrypt' do
    it 'should encrypt and sign the data using the intercept' do
      AEAD::Cipher::AES_256_CBC_HMAC_SHA_256.stub(:generate_nonce).and_return(TestValues::InitializationVector)
      master_key = Trustworthy::MasterKey.new(BigDecimal.new('6'), BigDecimal.new('24'))
      ciphertext = master_key.encrypt(TestValues::Plaintext)
      expect(ciphertext).to eq(TestValues::Ciphertext)
    end
  end

  describe 'decrypt' do
    it 'should decrypt and verify the data using the intercept' do
      master_key = Trustworthy::MasterKey.new(BigDecimal.new('6'), BigDecimal.new('24'))
      plaintext = master_key.decrypt(TestValues::Ciphertext)
      expect(plaintext).to eq(TestValues::Plaintext)
    end

    it 'should raise an invalid signature error if signatures do not match' do
      master_key = Trustworthy::MasterKey.new(BigDecimal.new('6'), BigDecimal.new('24'))
      ciphertext = TestValues::Ciphertext.dup
      ciphertext[0] = ciphertext[0].next
      expect { master_key.decrypt(ciphertext) }.to raise_error(ArgumentError, 'ciphertext failed authentication step')
    end
  end
end

