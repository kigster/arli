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

    attr_accessor :dependencies, :file_hash, :file, :lib_path, :resolved

    def initialize(lib_path: Arli.library_path,
                   arlifile_path: nil)

      self.lib_path = lib_path
      self.file     = arlifile_path ? "#{arlifile_path}/#{Arli::Config::DEFAULT_FILENAME}" :
                        Arli::Config::DEFAULT_FILENAME
      raise(Arli::Errors::ArliFileNotFound, 'Arlifile could not be found') unless file || !File.exist?(file)
      self.dependencies = []

      parse!
    end


    def libraries
      self.dependencies
    end

    def within_lib_path
      FileUtils.mkpath(lib_path) unless Dir.exist?(lib_path)
      Dir.chdir(lib_path) do
        yield if block_given?
      end
    end

    def each_dependency(&_block)
      within_lib_path do
        dependencies.each do |dependency|
          yield(dependency)
        end
      end
    end

    def error(*args)
      STDERR.puts *args.join("\n")
    end

    def info(*args)
      STDOUT.puts *args.join("\n") if Arli.debug?
    end

    private

    def parse!
      self.file_hash    = ::YAML.load(::File.read(self.file))
      self.dependencies = file_hash['dependencies'].map do |lib|
        ::Arduino::Library::Model.from_hash(lib)
      end
    end

  end
end
