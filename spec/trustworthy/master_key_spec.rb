require 'spec_helper'

describe Trustworthy::MasterKey do
  it 'should encrypt and decrypt a master_key' do
    master_key = Trustworthy::MasterKey.create
    key1 = master_key.create_key
    key2 = master_key.create_key

    ciphertext = master_key.encrypt('foobar')

    new_master_key = Trustworthy::MasterKey.create_from_keys(key1, key2)
    plaintext = new_master_key.decrypt(ciphertext)
    plaintext.should == 'foobar'
  end

  it 'should function with any 2 of n keys' do
    master_key1 = Trustworthy::MasterKey.create
    key1 = master_key1.create_key
    key2 = master_key1.create_key

    ciphertext = master_key1.encrypt('foobar')

    master_key2 = Trustworthy::MasterKey.create_from_keys(key1, key2)
    key3 = master_key2.create_key

    master_key3 = Trustworthy::MasterKey.create_from_keys(key1, key3)
    plaintext = master_key3.decrypt(ciphertext)
    plaintext.should == 'foobar'
  end

  describe 'self.create' do
    it 'should generate a random slope and intercept' do
      Trustworthy::Random.stub(:number).and_return(BigDecimal.new('10'))
      master_key = Trustworthy::MasterKey.create
      key = master_key.create_key
      key.x.should == 10
      key.y.should == 110
    end
  end

  describe 'self.create_from_keys' do
    it 'should calculate the slope and intercept given two keys' do
      Trustworthy::Random.stub(:number).and_return(BigDecimal.new('10'))

      key1 = Trustworthy::Key.new(BigDecimal.new('2'), BigDecimal.new('30'))
      key2 = Trustworthy::Key.new(BigDecimal.new('5'), BigDecimal.new('60'))

      master_key = Trustworthy::MasterKey.create_from_keys(key1, key2)
      new_key = master_key.create_key
      new_key.x.should == 10
      new_key.y.should == 110
    end
  end

  describe 'create_key' do
    it 'should define a new key' do
      master_key = Trustworthy::MasterKey.new(BigDecimal.new('6'), BigDecimal.new('24'))
      key = master_key.create_key
      key.x.should_not == 0
      key.y.should_not == 0
    end
  end

  describe 'encrypt' do
    it 'should encrypt and sign the data using the intercept' do
      Trustworthy::Random.stub(:bytes).and_return(Trustworthy::TestValues::InitializationVector)
      master_key = Trustworthy::MasterKey.new(BigDecimal.new('6'), BigDecimal.new('24'))
      ciphertext = master_key.encrypt('foobar')
      ciphertext.should == ['0438a89ef9e5792849ef611bff0e7b405a84ac515461489499679ca77ade6a6a39164ec082fb8b7336d3c5500af99dcbde056af859baa7e72c4c2661651e88d5'].pack('H*')
    end
  end

  describe 'decrypt' do
    it 'should decrypt and verify the data using the intercept' do
      master_key = Trustworthy::MasterKey.new(BigDecimal.new('6'), BigDecimal.new('24'))
      ciphertext = ['0438a89ef9e5792849ef611bff0e7b405a84ac515461489499679ca77ade6a6a39164ec082fb8b7336d3c5500af99dcbde056af859baa7e72c4c2661651e88d5'].pack('H*')
      plaintext = master_key.decrypt(ciphertext)
      plaintext.should == 'foobar'
    end

    it 'should raise an invalid signature error if signatures do not match' do
      master_key = Trustworthy::MasterKey.new(BigDecimal.new('6'), BigDecimal.new('24'))
      ciphertext = ['00000000000000000000000000000000000000005461489499679ca77ade6a6a39164ec082fb8b7336d3c5500af99dcbde056af859baa7e72c4c2661651e88d5'].pack('H*')
      expect { master_key.decrypt(ciphertext) }.to raise_error('invalid signature')
    end
  end
end
