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
  CipherAlgorithm = 'AES-256-CBC-HMAC-SHA-256'
  Cipher = AEAD::Cipher.new(CipherAlgorithm)
end
