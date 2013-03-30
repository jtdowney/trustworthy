require 'spec_helper'

describe Trustworthy::Prompt do
  let(:test_key) { Trustworthy::Key.new(BigDecimal.new('1'), BigDecimal.new('2')) }

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

  describe 'add_user_key' do
    it 'should prompt for two user keys' do
      HighLine::Simulate.with(
        'user3',
        'password',
        'password'
      ) do
        prompt = Trustworthy::Prompt.new(TestValues::SettingsFile, $terminal)
        username = prompt.add_user_key(test_key)
        username.should == 'user3'
      end
    end

    it 'should confirm passwords' do
      HighLine::Simulate.with(
        'user3',
        'password1',
        'password2',
        'password1',
        'password1'
      ) do
        prompt = Trustworthy::Prompt.new(TestValues::SettingsFile, $terminal)
        username = prompt.add_user_key(test_key)
        username.should == 'user3'
      end
    end

    it 'should require a unique username' do
      create_config(TestValues::SettingsFile)

      HighLine::Simulate.with(
        'user1',
        'user3',
        'password',
        'password'
      ) do
        prompt = Trustworthy::Prompt.new(TestValues::SettingsFile, $terminal)
        prompt.should_receive(:_error).with('Key user1 is already in use')
        username = prompt.add_user_key(test_key)
        username.should == 'user3'
      end
    end
  end

  describe 'unlock_master_key' do
    it 'should prompt for two user keys' do
      HighLine::Simulate.with(
        'user1',
        'password1',
        'user2',
        'password2'
      ) do
        prompt = Trustworthy::Prompt.new(TestValues::SettingsFile, $terminal)
        master_key = prompt.unlock_master_key
        master_key.should == TestValues::MasterKey
      end
    end

    it 'should raise an error if not recoverable' do
      File.open(TestValues::SettingsFile, 'w') do |file|
        file.write(YAML.dump({}))
      end

      expect do
        prompt = Trustworthy::Prompt.new(TestValues::SettingsFile, $terminal)
        master_key = prompt.unlock_master_key
        master_key.should == TestValues::MasterKey
      end.to raise_error('must have two keys to unlock master key')
    end

    it 'should require two distinct keys to unlock' do
      HighLine::Simulate.with(
        'user1',
        'password1',
        'user1',
        'user2',
        'password2'
      ) do
        prompt = Trustworthy::Prompt.new(TestValues::SettingsFile, $terminal)
        prompt.should_receive(:_error).with('Key user1 is already in use')
        prompt.unlock_master_key
      end
    end

    it 'should required an existing user for the first key' do
      HighLine::Simulate.with(
        'missing',
        'user1',
        'password1',
        'user2',
        'password2'
      ) do
        prompt = Trustworthy::Prompt.new(TestValues::SettingsFile, $terminal)
        prompt.should_receive(:_error).with('Key missing does not exist')
        prompt.unlock_master_key
      end
    end

    it 'should required an existing user for the second key' do
      HighLine::Simulate.with(
        'user1',
        'password1',
        'missing',
        'user2',
        'password2'
      ) do
        prompt = Trustworthy::Prompt.new(TestValues::SettingsFile, $terminal)
        prompt.should_receive(:_error).with('Key missing does not exist')
        prompt.unlock_master_key
      end
    end

    it 'should prompt for the correct password for the first key' do
      HighLine::Simulate.with(
        'user1',
        'bad_password',
        'password1',
        'user2',
        'password2'
      ) do
        prompt = Trustworthy::Prompt.new(TestValues::SettingsFile, $terminal)
        prompt.should_receive(:_error).with('Password incorrect for user1')
        prompt.unlock_master_key
      end
    end

    it 'should prompt for the correct password for the second key' do
      HighLine::Simulate.with(
        'user1',
        'password1',
        'user2',
        'bad_password',
        'password2'
      ) do
        prompt = Trustworthy::Prompt.new(TestValues::SettingsFile, $terminal)
        prompt.should_receive(:_error).with('Password incorrect for user2')
        prompt.unlock_master_key
      end
    end
  end
end
