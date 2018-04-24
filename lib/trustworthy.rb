require 'aead'
require 'base64'
require 'bigdecimal'
require 'date'
require 'highline'
require 'hkdf'
require 'scrypt'
require 'securerandom'
require 'yaml/store'

require 'trustworthy/key'
require 'trustworthy/master_key'
require 'trustworthy/prompt'
require 'trustworthy/random'
require 'trustworthy/settings'
require 'trustworthy/version'

module Trustworthy
  CipherAlgorithm = 'AES-256-CBC-HMAC-SHA-256'.freeze
  Cipher = AEAD::Cipher.new(CipherAlgorithm)
  SCryptParams = {
    max_time: 5,
    max_memfrac: 0.75,
    max_mem: 16 * 1024 * 1024
  }.freeze
end
