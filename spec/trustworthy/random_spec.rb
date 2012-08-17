require 'spec_helper'

describe Trustworthy::Random do
  describe 'self.number' do
    it 'should return a random number' do
      random = Trustworthy::Random.number
      random.should_not == Trustworthy::Random.number
    end

    it 'should return a number up to a given byte size' do
      random = Trustworthy::Random.number(2)
      random.should <= 2 ** 16
    end
  end

  describe 'self.bytes' do
    it 'should return a string of the given length' do
      bytes = Trustworthy::Random.bytes(16)
      bytes.size.should == 16
    end

    it 'should return a random string' do
      bytes1 = Trustworthy::Random.bytes(16)
      bytes2 = Trustworthy::Random.bytes(16)
      bytes1.should_not == bytes2
    end
  end
end
