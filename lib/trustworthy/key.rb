module Trustworthy
  class Key
    attr_reader :x, :y

    def self.create(slope, intercept)
      x = Trustworthy::Random.number
      y = slope * x + intercept
      new(x, y)
    end

    def self.create_from_string(str)
      x, y = str.split(',').map { |n| BigDecimal.new(n) }
      Trustworthy::Key.new(x, y)
    end

    def initialize(x, y)
      @x = x
      @y = y
    end

    def to_s
      "#{x.to_s('F')},#{y.to_s('F')}"
    end
  end
end
