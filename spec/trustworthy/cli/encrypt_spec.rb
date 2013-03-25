require 'spec_helper'

describe Trustworthy::CLI::Encrypt do
  before(:each) do
    $terminal.stub(:say)
    AEAD::Cipher::AES_256_CBC_HMAC_SHA_256.stub(:generate_nonce).and_return(TestValues::InitializationVector)
  end

  around(:each) do |example|
    within_construct do |construct|
      construct.file(TestValues::SettingsFile)
      construct.file('input.txt', TestValues::Plaintext)
      construct.file('output.txt')
      create_config(TestValues::SettingsFile)
      example.run
    end
  end

  describe 'run' do
    it 'should unlock the master key and encrypt the file' do
      HighLine::Simulate.with(
        'user1',
        'password1',
        'user2',
        'password2'
      ) do
        Trustworthy::CLI::Encrypt.new.run(['-i', 'input.txt', '-o', 'output.txt'])
      end

      File.open('output.txt', 'rb') do |file|
        ciphertext = file.read
        ciphertext.should == TestValues::EncryptedFile
      end
    end

    it 'should require an input file' do
      HighLine::Simulate.with(
        'user1',
        'password1',
        'user2',
        'password2'
      ) do
        encrypt = Trustworthy::CLI::Encrypt.new
        encrypt.should_receive(:print_help)
        $terminal.should_receive(:say).with('Must provide an input file')
        encrypt.run([])
      end
    end

    it 'should require an output file' do
      HighLine::Simulate.with(
        'user1',
        'password1',
        'user2',
        'password2'
      ) do
        encrypt = Trustworthy::CLI::Encrypt.new
        encrypt.should_receive(:print_help)
        $terminal.should_receive(:say).with('Must provide an output file')
        encrypt.run(['-i', 'input.txt'])
      end
    end
  end
end
