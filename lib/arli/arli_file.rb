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

    def initialize(config: Arli.config, libraries: [])
      self.library_path = config.libraries.path
      FileUtils.mkpath(library_path) unless Dir.exist?(library_path)

      if libraries && !libraries.empty?
        self.dependencies = libraries.map{ |lib| make_lib(lib) }
      else
        self.file         = "#{config.arlifile.path}/#{config.arlifile.name}"
        unless file && File.exist?(file)
          raise(Arli::Errors::ArliFileNotFound,
                "Arlifile could not be found at\n#{file.bold.yellow}")
        end
        self.dependencies = parse_file
      end
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
      file_hash['dependencies'].map { |lib| make_lib(lib) }
    end

    def make_lib(lib)
      ::Arli::Library.new(::Arduino::Library::Model.from(lib))
    end
  end
end
