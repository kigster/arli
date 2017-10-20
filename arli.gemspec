# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'arli/version'

Arli::DESCRIPTION = <<-eof
  Super simple and installer of any number of Github repos.
  It was created to provide Arduino projects with an easy to use 
  dependency manager.
eof

Gem::Specification.new do |spec|
  spec.name          = 'arli'
  spec.version       = Arli::VERSION
  spec.authors       = ['Konstantin Gredeskoul']
  spec.email         = ['kigster@gmail.com']

  spec.summary       = Arli::DESCRIPTION
  spec.description   = Arli::DESCRIPTION
  spec.homepage      = 'https://github.com/kigster/arli'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'hashie'
  spec.add_dependency 'colored2'


  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-its'
end
