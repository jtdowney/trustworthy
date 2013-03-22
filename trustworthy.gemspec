# -*- encoding: utf-8 -*-
$:.unshift File.expand_path('../lib', __FILE__)
require 'trustworthy/version'

Gem::Specification.new do |s|
  s.name        = 'trustworthy'
  s.version     = Trustworthy::VERSION
  s.authors     = ['John Downey']
  s.email       = ['jdowney@gmail.com']
  s.homepage    = 'http://github.com/jtdowney/trustworthy'
  s.license     = 'MIT'
  s.summary     = %q{Launch processes while keeping secrets encrypted on disk}
  s.description = %q{Implements a special case (k = 2) of Adi Shamir's secret sharing algorithm. This allows secret files to be encrypted on disk but loaded into a process on start if two keys are available.}

  s.files        = Dir.glob('{lib,spec}/**/*.rb') + %w{bin/trustworthy README.md}
  s.test_files   = Dir.glob('spec/**/*')
  s.require_path = 'lib'
  s.bindir       = 'bin'
  s.executables  = ['trustworthy']

  s.add_dependency 'aead', '~> 1.6'
  s.add_dependency 'commander', '~> 4.1'
  s.add_dependency 'hkdf', '~> 0.2.0'
  s.add_dependency 'posix-spawn', '~> 0.3.6'
  s.add_dependency 'scrypt', '~> 1.1'
  s.add_development_dependency 'test-construct', '1.2.0'
  s.add_development_dependency 'rspec', '2.13'
  s.add_development_dependency 'rake', '10.0.3'
end
