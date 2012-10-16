require 'spec_helper'

describe Trustworthy::Crypto do
  before(:each) do
    @crypto = Trustworthy::Crypto.new(Trustworthy::TestValues::EncryptionKey, Trustworthy::TestValues::AuthenticationKey)
  end

  describe 'sign' do
    it 'should sign the input using the authentication key' do
      signature = @crypto.sign('foobar')
      signature.should == ['f9e948d9259d35e729b14e370a7456ec4b22d2a0a1d5daa1accbeb54f414865e'].pack('H*')
    end
  end

  describe 'valid_signature?' do
    it 'should return true when the signature matches the data' do
      given_signature = ['f9e948d9259d35e729b14e370a7456ec4b22d2a0a1d5daa1accbeb54f414865e'].pack('H*')
      @crypto.should be_valid_signature(given_signature, 'foobar')
    end

    it 'should return false when the signature does not match the data' do
      given_signature = ['4d15a6427d6b56e07b819ff0a147dd8ff77b1b5fafd33f9071b0359755edde42'].pack('H*')
      @crypto.should_not be_valid_signature(given_signature, 'foobar')
    end
  end

  describe 'encrypt' do
    it 'should encrypt the input using the encryption key' do
      Trustworthy::Random.stub(:bytes).and_return(Trustworthy::TestValues::InitializationVector)
      ciphertext = @crypto.encrypt('foobar')
      ciphertext.should == ['39164ec082fb8b7336d3c5500af99dcbf3af2b0abd6f2ac79f1a76cb4e092a7c'].pack('H*')
    end
  end

  describe 'decrypt' do
    it 'should decrypt the input using the encryption key' do
      ciphertext = ['39164ec082fb8b7336d3c5500af99dcbf3af2b0abd6f2ac79f1a76cb4e092a7c'].pack('H*')
      plaintext = @crypto.decrypt(ciphertext)
      plaintext.should == 'foobar'
    end
  end
end
