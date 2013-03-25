require 'aead'
require 'bigdecimal'
require 'hkdf'
require 'scrypt'
require 'securerandom'
require 'trustworthy/key'
require 'trustworthy/master_key'
require 'trustworthy/random'
require 'trustworthy/settings'
require 'trustworthy/version'
require 'yaml/store'

module Trustworthy
  CipherAlgorithm = 'AES-256-CBC-HMAC-SHA-256'
  Cipher = AEAD::Cipher.new(CipherAlgorithm)
end
