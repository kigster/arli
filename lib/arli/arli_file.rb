require 'arli'
require 'arduino/library'
require 'yaml'

module Arli
  class ArliFile
    require 'arduino/library/include'

    extend Forwardable
    def_delegators :@dependencies, *(Array.new.methods - Object.methods)

    DEFAULT_FILE_NAME = 'ArliFile.yml'.freeze

    attr_accessor :dependencies, :arli_hash, :file

    def initialize(file = DEFAULT_FILE_NAME)
      self.file         = file
      self.arli_hash    = ::YAML.load(File.read(file))
      self.dependencies = arli_hash['dependencies'].map do |lib_hash|
        library_from(lib_hash)
      end
    end
  end
end
