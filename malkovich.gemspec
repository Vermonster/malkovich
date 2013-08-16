# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'malkovich/capistrano/version'

Gem::Specification.new do |spec|
  spec.name          = "malkovich"
  spec.version       = Malkovich::Capistrano::VERSION
  spec.authors       = ["Steve Masterman"]
  spec.email         = ["steve@vermonster.com"]
  spec.description   = %q{Capistrano tasks and settings for Puppet, Vagrant/EC2, Ubuntu}
  spec.summary   = %q{Capistrano tasks and settings for Puppet, Vagrant/EC2, Ubuntu}

  spec.homepage      = "https://github.com/vermonster/malkovich"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_dependency "capistrano"
end
