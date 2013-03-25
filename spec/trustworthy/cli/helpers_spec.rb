require 'spec_helper'

describe Trustworthy::CLI::Helpers do
  def test_klass
    klass = Class.new
    klass.send(:include, Trustworthy::CLI::Helpers)
    klass
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
      $terminal.should_receive(:say).with('Key user1 is already in use')
      HighLine::Simulate.with(
        'user1',
        'password1',
        'user1',
        'user2',
        'password2'
      ) do
        Trustworthy::Settings.open(TestValues::SettingsFile) do |settings|
          master_key = test_klass.new.unlock_master_key(settings)
          master_key.should == TestValues::MasterKey
        end
      end
    end

    it 'should required an existing user for the first key' do
      $terminal.should_receive(:say).with('Key missing does not exist')
      HighLine::Simulate.with(
        'missing',
        'user1',
        'bad_password',
        'password1',
        'user2',
        'password2'
      ) do
        Trustworthy::Settings.open(TestValues::SettingsFile) do |settings|
          master_key = test_klass.new.unlock_master_key(settings)
          master_key.should == TestValues::MasterKey
        end
      end
    end

    it 'should required an existing user for the second key' do
      $terminal.should_receive(:say).with('Key missing does not exist')
      HighLine::Simulate.with(
        'user1',
        'bad_password',
        'password1',
        'missing',
        'user2',
        'password2'
      ) do
        Trustworthy::Settings.open(TestValues::SettingsFile) do |settings|
          master_key = test_klass.new.unlock_master_key(settings)
          master_key.should == TestValues::MasterKey
        end
      end
    end

    it 'should prompt for the correct password for the first key' do
      $terminal.should_receive(:say).with('Password incorrect for user1')
      HighLine::Simulate.with(
        'user1',
        'bad_password',
        'password1',
        'user2',
        'password2'
      ) do
        Trustworthy::Settings.open(TestValues::SettingsFile) do |settings|
          master_key = test_klass.new.unlock_master_key(settings)
          master_key.should == TestValues::MasterKey
        end
      end
    end

    it 'should prompt for the correct password for the second key' do
      $terminal.should_receive(:say).with('Password incorrect for user2')
      HighLine::Simulate.with(
        'user1',
        'password1',
        'user2',
        'bad_password',
        'password2'
      ) do
        Trustworthy::Settings.open(TestValues::SettingsFile) do |settings|
          master_key = test_klass.new.unlock_master_key(settings)
          master_key.should == TestValues::MasterKey
        end
      end
    end
  end
end
