require 'spec_helper'

describe Trustworthy::CLI::Encrypt do
  before(:each) do
    allow($terminal).to receive(:say)
    allow(AEAD::Cipher::AES_256_CBC_HMAC_SHA_256).to receive(:generate_nonce).and_return(TestValues::InitializationVector)
  end

  around(:each) do |example|
    within_construct do |construct|
      construct.file(TestValues::SettingsFile)
      construct.file('input.txt', TestValues::Plaintext)
      construct.file('input.txt.tw')
      construct.file('output.txt')
      create_config(TestValues::SettingsFile)
      example.run
    end
  end

  describe 'run' do
    it 'should unlock the master key and encrypt the file' do
      HighLine::Simulate.with(
        'user1',
        'P@ssw0rd1',
        'user2',
        'P@ssw0rd2'
      ) do
        Trustworthy::CLI::Encrypt.new.run(['input.txt'])
      end

      ciphertext = File.read('input.txt.tw')
      expect(ciphertext).to eq(TestValues::EncryptedFile)

      ciphertext = File.read('output.txt')
      expect(ciphertext).to be_empty
    end

    it 'should require an input file' do
      encrypt = Trustworthy::CLI::Encrypt.new
      expect(encrypt).to receive(:print_help)
      encrypt.run([])
    end

    it 'should allow a named output file' do
      HighLine::Simulate.with(
        'user1',
        'P@ssw0rd1',
        'user2',
        'P@ssw0rd2'
      ) do
        Trustworthy::CLI::Encrypt.new.run(['input.txt', '-o', 'output.txt'])
      end

      ciphertext = File.read('output.txt')
      expect(ciphertext).to eq(TestValues::EncryptedFile)

      ciphertext = File.read('input.txt.tw')
      expect(ciphertext).to be_empty
    end
  end
end
