require 'spec_helper'

describe Trustworthy::CLI::Init do
  before(:each) do
    allow($terminal).to receive(:say)
  end

  around(:each) do |example|
    within_construct do |construct|
      construct.file(TestValues::SettingsFile)
      example.run
    end
  end

  describe 'run' do
    it 'should not allow any previous keys to exist' do
      create_config(TestValues::SettingsFile)
      expect($terminal).to receive(:say).with('Config trustworthy.yml already exists')
      Trustworthy::CLI::Init.new.run([])
    end

    it 'should write a settings file' do
      HighLine::Simulate.with(
        'user1',
        'P@ssw0rd1',
        'P@ssw0rd1',
        'user2',
        'P@ssw0rd2',
        'P@ssw0rd2'
      ) do
        Trustworthy::CLI::Init.new.run([])
      end

      contents = File.read(TestValues::SettingsFile)
      subkeys = YAML.load(contents)
      expect(subkeys).to have_key('user1')
      expect(subkeys).to have_key('user2')
    end

    it 'should write to a specified file' do
      filename = 'test.yml'
      within_construct do |construct|
        construct.file(filename)
        HighLine::Simulate.with(
          'user1',
          'P@ssw0rd1',
          'P@ssw0rd1',
          'user2',
          'P@ssw0rd2',
          'P@ssw0rd2'
        ) do
          Trustworthy::CLI::Init.new.run(['-c', filename])
        end

        contents = File.read(filename)
        subkeys = YAML.load(contents)
        expect(subkeys).to have_key('user1')
        expect(subkeys).to have_key('user2')
      end
    end

    it 'should generate the specified number of keys' do
      HighLine::Simulate.with(
        'user1',
        'P@ssw0rd1',
        'P@ssw0rd1',
        'user2',
        'P@ssw0rd2',
        'P@ssw0rd2',
        'user3',
        'P@ssw0rd3',
        'P@ssw0rd3'
      ) do
        Trustworthy::CLI::Init.new.run(['-k', '3'])
      end

      contents = File.read(TestValues::SettingsFile)
      subkeys = YAML.load(contents)
      expect(subkeys).to have_key('user1')
      expect(subkeys).to have_key('user2')
      expect(subkeys).to have_key('user3')
    end

    it 'should require two subkeys minimum' do
      init = Trustworthy::CLI::Init.new
      expect(init).to receive(:print_help)
      init.run(['-k', '1'])
    end
  end
end
