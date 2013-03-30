require 'spec_helper'

describe Trustworthy::CLI::Decrypt do
  before(:each) do
    $terminal.stub(:say)
  end

  around(:each) do |example|
    within_construct do |construct|
      construct.file(TestValues::SettingsFile)
      construct.file('input.txt', TestValues::EncryptedFile)
      construct.file('output.txt')
      create_config(TestValues::SettingsFile)
      example.run
    end
  end

  describe 'run' do
    it 'should unlock the master key and decrypt the file' do
      HighLine::Simulate.with(
        'user1',
        'password1',
        'user2',
        'password2'
      ) do
        Trustworthy::CLI::Decrypt.new.run(['-i', 'input.txt', '-o', 'output.txt'])
      end

      File.open('output.txt', 'rb') do |file|
        ciphertext = file.read
        ciphertext.should == TestValues::Plaintext
      end
    end

    it 'should require an input file' do
      HighLine::Simulate.with(
        'user1',
        'password1',
        'user2',
        'password2'
      ) do
        decrypt = Trustworthy::CLI::Encrypt.new
        decrypt.should_receive(:print_help)
        decrypt.run([])
      end
    end

    it 'should require an output file' do
      HighLine::Simulate.with(
        'user1',
        'password1',
        'user2',
        'password2'
      ) do
        decrypt = Trustworthy::CLI::Encrypt.new
        decrypt.should_receive(:print_help)
        decrypt.run(['-i', 'input.txt'])
      end
    end
  end
end
