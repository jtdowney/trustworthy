require 'spec_helper'

describe Trustworthy::Settings do
  before(:each) do
    SCrypt::Engine.stub(:generate_salt).and_return('400$8$1b$3e31f076a3226825')
    Trustworthy::Random.stub(:bytes).and_return(Trustworthy::TestValues::InitializationVector)

    key = Trustworthy::Key.new(BigDecimal.new('2'), BigDecimal.new('3'))
    @settings = Trustworthy::Settings.new
  end

  describe 'add_key' do
    it 'encrypts and signs the key with the password' do
      key = Trustworthy::Key.new(BigDecimal.new('2'), BigDecimal.new('3'))
      settings = Trustworthy::Settings.new
      settings.add_key(key, 'user', 'password1')
      settings.keys['user']['salt'].should == '400$8$1b$3e31f076a3226825'
      settings.keys['user']['authentication'].should == ['20c274efc68a460568853cc4be586183012769a312549d1aa57e29a36ec1503d'].pack('H*')
      settings.keys['user']['ciphertext'].should == ['39164ec082fb8b7336d3c5500af99dcb17d2e60496ed553dfab4b05c568aa926'].pack('H*')
    end
  end

  describe 'add_secret' do
    it 'adds a secret file name with an environment' do
      settings = Trustworthy::Settings.new
      settings.add_secret('foo', 'foo.enc')
      settings.secrets['foo'].should == 'foo.enc'
    end
  end

  describe 'unlock_key' do
    it 'verifies and decrypts the key with the password' do
      key = Trustworthy::Key.new(BigDecimal.new('2'), BigDecimal.new('3'))
      settings = Trustworthy::Settings.new
      settings.add_key(key, 'user', 'password1')
      unlocked_key = settings.unlock_key('user', 'password1')
      unlocked_key.x.should == BigDecimal.new('2')
      unlocked_key.y.should == BigDecimal.new('3')
    end
  end


  describe 'write' do
    it 'writes key information to the given file' do
      key = Trustworthy::Key.new(BigDecimal.new('2'), BigDecimal.new('3'))
      settings = Trustworthy::Settings.new
      settings.add_key(key, 'user', 'password1')
      FakeFS do
        settings.write('settings.yml')

        data = File.read('settings.yml')
        yaml = YAML.load(data)
        yaml['keys']['user']['salt'].should == '400$8$1b$3e31f076a3226825'
        yaml['keys']['user']['authentication'].should == ['20c274efc68a460568853cc4be586183012769a312549d1aa57e29a36ec1503d'].pack('H*')
        yaml['keys']['user']['ciphertext'].should == ['39164ec082fb8b7336d3c5500af99dcb17d2e60496ed553dfab4b05c568aa926'].pack('H*')
      end
    end
  end

  describe 'self.load' do
    it 'loads the key information from the given file' do
      FakeFS do
        File.open('settings.yml', 'w') do |file|
          file.write(<<-EOF)
keys:
  user:
    salt: 400$8$1b$3e31f076a3226825
    ciphertext: !binary |-
      ORZOwIL7i3M208VQCvmdyxfS5gSW7VU9+rSwXFaKqSY=
    authentication: !binary |-
      IMJ078aKRgVohTzEvlhhgwEnaaMSVJ0apX4po27BUD0=
EOF
        end

        settings = Trustworthy::Settings.load('settings.yml')
        settings.keys['user']['salt'].should == '400$8$1b$3e31f076a3226825'
        settings.keys['user']['authentication'].should == ['20c274efc68a460568853cc4be586183012769a312549d1aa57e29a36ec1503d'].pack('H*')
        settings.keys['user']['ciphertext'].should == ['39164ec082fb8b7336d3c5500af99dcb17d2e60496ed553dfab4b05c568aa926'].pack('H*')
      end
    end
  end
end
