require 'spec_helper'

describe Trustworthy::CLI::Init do
  before(:each) do
    $terminal.stub(:say)
  end

  around(:each) do |example|
    within_construct do |construct|
      construct.file(TestValues::SettingsFile)
      example.run
    end
  end

  describe 'run' do
    it 'should write a settings file' do
      HighLine::Simulate.with(
        'user1',
        'password1',
        'password1',
        'user2',
        'password2',
        'password2'
      ) do
        Trustworthy::CLI::Init.new.run([])
      end

      contents = File.read(TestValues::SettingsFile)
      subkeys = YAML.load(contents)
      subkeys.should have_key('user1')
      subkeys.should have_key('user2')
    end

    it 'should confirm passwords' do
      HighLine::Simulate.with(
        'user1',
        'password1',
        'password2',
        'password1',
        'password1',
        'user2',
        'password2',
        'password2'
      ) do
        Trustworthy::CLI::Init.new.run([])
      end

      contents = File.read(TestValues::SettingsFile)
      subkeys = YAML.load(contents)
      subkeys.should have_key('user1')
      subkeys.should have_key('user2')
    end

    it 'should write to a specified file' do
      filename = 'test.yml'
      within_construct do |construct|
        construct.file(filename)
        HighLine::Simulate.with(
          'user1',
          'password1',
          'password1',
          'user2',
          'password2',
          'password2'
        ) do
          Trustworthy::CLI::Init.new.run(['-c', filename])
        end

        contents = File.read(filename)
        subkeys = YAML.load(contents)
        subkeys.should have_key('user1')
        subkeys.should have_key('user2')
      end
    end

    it 'should generate the specified number of keys' do
      HighLine::Simulate.with(
        'user1',
        'password1',
        'password1',
        'user2',
        'password2',
        'password2',
        'user3',
        'password3',
        'password3'
      ) do
        Trustworthy::CLI::Init.new.run(['-k', '3'])
      end

      contents = File.read(TestValues::SettingsFile)
      subkeys = YAML.load(contents)
      subkeys.should have_key('user1')
      subkeys.should have_key('user2')
      subkeys.should have_key('user3')
    end

    it 'should require two subkeys minimum' do
      init = Trustworthy::CLI::Init.new
      init.should_receive(:print_help)
      $terminal.should_receive(:say).with('Must generate at least two keys')
      init.run(['-k', '1'])
    end
  end
end
