$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'trustworthy/version'

Gem::Specification.new do |s|
  s.name        = 'trustworthy'
  s.version     = Trustworthy::VERSION
  s.authors     = ['John Downey']
  s.email       = ['jdowney@gmail.com']
  s.homepage    = 'http://github.com/jtdowney/trustworthy'
  s.license     = 'MIT'
  s.summary     = 'Encrypt and decrypt files with multiple key holders'
  s.description = "Implements a special case (k = 2) of Adi Shamir's secret sharing algorithm.
                   This allows secret files to be encrypted on disk and require two secret holders to decrypt it."

  s.files        = Dir.glob('{lib,spec}/**/*.rb') + %w[bin/trustworthy README.md LICENSE]
  s.test_files   = Dir.glob('spec/**/*')
  s.require_path = 'lib'
  s.bindir       = 'bin'
  s.executables  = ['trustworthy']

  s.add_dependency 'aead', '~> 1.8'
  s.add_dependency 'highline', '~> 1.7'
  s.add_dependency 'hkdf', '~> 0.3.0'
  s.add_dependency 'scrypt', '~> 3.0'
  s.add_development_dependency 'rake', '12.1.0'
  s.add_development_dependency 'rspec', '3.7.0'
  s.add_development_dependency 'rubocop', '0.50.0'
  s.add_development_dependency 'test_construct', '2.0.1'
  s.add_development_dependency 'timecop', '0.9.1'
end
