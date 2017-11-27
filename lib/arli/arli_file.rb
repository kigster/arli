require 'arli'
require 'yaml'
require 'forwardable'
require 'arduino/library'

module Arli
  class ArliFile
    require 'arduino/library/include'

    include Enumerable
    extend Forwardable

    def_delegators :@dependencies, *(Array.new.methods - Object.methods)

    attr_accessor :dependencies,
                  :file_hash,
                  :file,
                  :library_path

    def initialize(config: Arli.config)
      self.library_path = config.libraries.path
      self.file         = "#{config.arlifile.path}/#{config.arlifile.name}"

      unless file && File.exist?(file)
        raise(Arli::Errors::ArliFileNotFound,
              "Arlifile could not be found at #{file}")
      end

      FileUtils.mkpath(library_path) unless Dir.exist?(library_path)
      self.dependencies = parse_file
    end

    def within_library_path
      Dir.chdir(library_path) do
        yield if block_given?
      end
    end

    def each_dependency(&block)
      within_library_path { dependencies.each(&block) }
    end

    private

    def parse_file
      self.file_hash = ::YAML.load(::File.read(self.file))
      file_hash['dependencies'].map do |lib|
        ::Arli::Library.new(::Arduino::Library::Model.from(lib))
      end
    end
  end
end
