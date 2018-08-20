# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'arli/version'

Arli::DESCRIPTION = <<-eof
  This is an Arduino helper toolkit that builds on top of the arduino-cmake
  project — a powerful alternative build system for Arduino. What Arli provides
  is capability to search for libraries by any attributes and regular expressions,
  install a whole set of libraries defined in a YAML file Arlifile, and finally,
  it can generate a brand new Sketch Project based on arduino-cmake, that builds
  out the box. Arli is a command line tool, so run "arli" after installing the gem
  for more information.
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

  spec.add_dependency 'arduino-library', '~> 0.6'

  spec.add_dependency 'awesome_print'
  spec.add_dependency 'colored2'

  spec.add_dependency 'dry-configurable'
  spec.add_dependency 'dry-types'
  spec.add_dependency 'dry-struct'

  spec.add_dependency 'hashie', '~> 3.5'
  spec.add_dependency 'require_dir', '~> 2'
  spec.add_dependency 'tty-cursor'

  spec.add_development_dependency 'aruba'
  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3'
  spec.add_development_dependency 'rspec-its'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'yard'
end
