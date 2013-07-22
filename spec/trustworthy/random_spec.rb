require 'spec_helper'

describe Trustworthy::Random do
  describe 'self.number' do
    it 'should return a random number' do
      random = Trustworthy::Random.number
      expect(random).to_not eq(Trustworthy::Random.number)
    end

    it 'should return a number up to a given byte size' do
      random = Trustworthy::Random.number(2)
      expect(random).to be <= 2 ** 16
    end
  end

  describe 'self.bytes' do
    it 'should return a string of the given length' do
      bytes = Trustworthy::Random.bytes(16)
      expect(bytes.size).to eq(16)
    end

    it 'should return a random string' do
      bytes1 = Trustworthy::Random.bytes(16)
      bytes2 = Trustworthy::Random.bytes(16)
      expect(bytes1).to_not eq(bytes2)
    end
  end
end
