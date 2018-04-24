require 'spec_helper'

describe Trustworthy::CLI::AddKey do
  before(:each) do
    allow($terminal).to receive(:say)
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
        'P@ssw0rd1',
        'user2',
        'P@ssw0rd2',
        'user3',
        'P@ssw0rd3',
        'P@ssw0rd3'
      ) do
        Trustworthy::CLI::AddKey.new.run([])
      end

      contents = File.read(TestValues::SettingsFile)
      subkeys = YAML.load(contents)
      expect(subkeys).to have_key('user1')
      expect(subkeys).to have_key('user2')
      expect(subkeys).to have_key('user3')
    end
  end
end
