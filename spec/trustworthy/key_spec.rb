require 'spec_helper'

describe Trustworthy::Key do
  describe 'self.create' do
    it 'should create a key along the slope and intercept' do
      Trustworthy::Random.stub(:number).and_return(BigDecimal.new('10'))
      key = Trustworthy::Key.create(6, 24)
      key.y.should == 84
    end
  end
end
