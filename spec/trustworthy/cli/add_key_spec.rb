require 'spec_helper'

describe Trustworthy::CLI::AddKey do
  before(:each) do
    $terminal.stub(:say)
  end

  around(:each) do |example|
    within_construct do |construct|
      construct.file(TestValues::SettingsFile)
      create_config(TestValues::SettingsFile)
      example.run
    end
  end

  describe 'run' do
    it 'should add a new user' do
      HighLine::Simulate.with(
        'user1',
        'password1',
        'user2',
        'password2',
        'user3',
        'password3',
        'password3'
      ) do
        Trustworthy::CLI::AddKey.new.run([])
      end

      contents = File.read(TestValues::SettingsFile)
      subkeys = YAML.load(contents)
      subkeys.should have_key('user1')
      subkeys.should have_key('user2')
      subkeys.should have_key('user3')
    end
  end
end
