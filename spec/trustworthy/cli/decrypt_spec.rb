require 'spec_helper'

describe Trustworthy::CLI::Decrypt do
  before(:each) do
    allow($terminal).to receive(:say)
  end

  around(:each) do |example|
    within_construct do |construct|
      construct.file(TestValues::SettingsFile)
      construct.file('input.txt.tw', TestValues::EncryptedFile)
      construct.file('input.txt')
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
        Trustworthy::CLI::Decrypt.new.run(['input.txt.tw'])
      end

      plaintext = File.read('input.txt')
      expect(plaintext).to eq(TestValues::Plaintext)

      plaintext = File.read('output.txt')
      expect(plaintext).to be_empty
    end

    it 'should require an input file' do
      HighLine::Simulate.with(
        'user1',
        'password1',
        'user2',
        'password2'
      ) do
        decrypt = Trustworthy::CLI::Decrypt.new
        expect(decrypt).to receive(:print_help)
        decrypt.run([])
      end
    end

    it 'should require an output file if input does not end in .tw' do
      HighLine::Simulate.with(
        'user1',
        'password1',
        'user2',
        'password2'
      ) do
        decrypt = Trustworthy::CLI::Decrypt.new
        expect(decrypt).to receive(:print_help)
        decrypt.run(['input.txt'])
      end
    end

    it 'should take an optional output file' do
      HighLine::Simulate.with(
        'user1',
        'password1',
        'user2',
        'password2'
      ) do
        Trustworthy::CLI::Decrypt.new.run(['input.txt.tw', '-o', 'output.txt'])
      end

      plaintext = File.read('output.txt')
      expect(plaintext).to eq(TestValues::Plaintext)

      plaintext = File.read('input.txt')
      expect(plaintext).to be_empty
    end

    it 'should error on non-trustworthy input files' do
      File.open('input.txt.tw', 'w+') do |file|
        file.write('bad file')
      end

      decrypt = Trustworthy::CLI::Decrypt.new
      expect(decrypt).to receive(:say).with('File input.txt.tw does not appear to be a trustworthy encrypted file')
      decrypt.run(['input.txt.tw'])
    end
  end
end
