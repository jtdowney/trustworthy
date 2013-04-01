module Trustworthy
  class Key
    attr_reader :x, :y

    def self.create(slope, intercept)
      x = Trustworthy::Random.number
      y = slope * x + intercept
      new(x, y)
    end

    def initialize(x, y)
      @x = x
      @y = y
    end
  end
end
