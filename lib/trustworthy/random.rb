module Trustworthy
  module Random
    def self.number(size = 32)
      raw_bytes = bytes(size)
      number = raw_bytes.unpack('H*').first.hex
      BigDecimal(number.to_s)
    end

    def self.bytes(size = 32)
      flags = File::RDONLY
      flags |= File::NOCTTY if defined? File::NOCTTY
      File.open(_source, flags) do |file|
        file.read(size)
      end
    end

    def self._source
      '/dev/urandom'
    end
  end
end
