# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-openssh-passwd/version'

Gem::Specification.new do |spec|
  spec.name          = "vagrant-openssh-passwd"
  spec.version       = Vagrant::OpenSshPasswd::VERSION
  spec.authors       = ["Taliesin Sisson"]
  spec.email         = ["taliesins@yahoo.com"]
  spec.summary       = "Generate passwd and group for OpenSSH for Vagrant before sync folder is run"
  spec.description   = "Recreate passwd and group for OpenSSH using L parameter, so that when machine is renamed or joined to AD, rsync can be used to sync folder still."
  spec.homepage      = "https://github.com/taliesins/vagrant-openssh-passwd"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", "< 11.0"
  spec.add_development_dependency "bundler", ">= 1.5.2", "<= 1.12.5"
  spec.add_development_dependency "coveralls", "~> 0.8.10", '>= 0.8.10'
  spec.add_development_dependency "rspec-core", '~> 3.4.2', '>= 3.4.2'
  spec.add_development_dependency "rspec-expectations", '~> 3.4.0', '>= 3.4.0'
  spec.add_development_dependency "rspec-mocks", '~> 3.4.1', '>= 3.4.1'
  spec.add_development_dependency "rspec-its", "~> 1.2.0", '>= 1.2.0'
end
