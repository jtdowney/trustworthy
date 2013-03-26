require 'spec_helper'

describe Trustworthy::CLI::Command do
  def test_command
    return @klass if @klass
    @klass = Class.new
    @klass.send(:include, Trustworthy::CLI::Command)
    @klass
  end

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

  describe 'unlock_master_key' do
    it 'should require two distinct keys to unlock' do
      command = test_command.new
      command.should_receive(:error).with('Key user1 is already in use')

      HighLine::Simulate.with(
        'user1',
        'password1',
        'user1',
        'user2',
        'password2'
      ) do
        Trustworthy::Settings.open(TestValues::SettingsFile) do |settings|
          master_key = command.unlock_master_key(settings)
          master_key.should == TestValues::MasterKey
        end
      end
    end

    it 'should required an existing user for the first key' do
      command = test_command.new
      command.should_receive(:error).with('Key missing does not exist')

      HighLine::Simulate.with(
        'missing',
        'user1',
        'password1',
        'user2',
        'password2'
      ) do
        Trustworthy::Settings.open(TestValues::SettingsFile) do |settings|
          master_key = command.unlock_master_key(settings)
          master_key.should == TestValues::MasterKey
        end
      end
    end

    it 'should required an existing user for the second key' do
      command = test_command.new
      command.should_receive(:error).with('Key missing does not exist')

      HighLine::Simulate.with(
        'user1',
        'password1',
        'missing',
        'user2',
        'password2'
      ) do
        Trustworthy::Settings.open(TestValues::SettingsFile) do |settings|
          master_key = command.unlock_master_key(settings)
          master_key.should == TestValues::MasterKey
        end
      end
    end

    it 'should prompt for the correct password for the first key' do
      command = test_command.new
      command.should_receive(:error).with('Password incorrect for user1')

      HighLine::Simulate.with(
        'user1',
        'bad_password',
        'password1',
        'user2',
        'password2'
      ) do
        Trustworthy::Settings.open(TestValues::SettingsFile) do |settings|
          master_key = command.unlock_master_key(settings)
          master_key.should == TestValues::MasterKey
        end
      end
    end

    it 'should prompt for the correct password for the second key' do
      command = test_command.new
      command.should_receive(:error).with('Password incorrect for user2')

      HighLine::Simulate.with(
        'user1',
        'password1',
        'user2',
        'bad_password',
        'password2'
      ) do
        Trustworthy::Settings.open(TestValues::SettingsFile) do |settings|
          master_key = command.unlock_master_key(settings)
          master_key.should == TestValues::MasterKey
        end
      end
    end
  end
end
