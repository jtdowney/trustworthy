require 'spec_helper'

describe Trustworthy::Key do
  describe 'self.create' do
    it 'should create a key along the slope and intercept' do
      allow(Trustworthy::Random).to receive(:number).and_return(BigDecimal.new('10'))
      key = Trustworthy::Key.create(6, 24)
      expect(key.y).to eq(84)
    end
  end

  describe 'self.create_from_string' do
    it 'should create a key from the string representation' do
      key = Trustworthy::Key.create_from_string('4.0,5.0')
      expect(key.x).to eq(BigDecimal.new('4.0'))
      expect(key.y).to eq(BigDecimal.new('5.0'))
    end
  end

  describe 'to_s' do
    it 'should return a set of points' do
      x = BigDecimal.new('4')
      y = BigDecimal.new('5')
      key = Trustworthy::Key.new(x, y)
      expect(key.to_s).to eq('4.0,5.0')
    end
  end
end
