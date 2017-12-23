require 'arli'
require 'yaml'
require 'forwardable'
require 'arduino/library'
require 'hashie/mash'
require 'hashie/extensions/symbolize_keys'
require 'arli/library'

module Arli
  class ArliFile
    require 'arduino/library/include'

    include Enumerable

    extend Forwardable
    def_delegators :@dependencies, *(Array.new.methods - Object.methods)

    include ::Arli::Library

    attr_accessor :dependencies,
                  :parsed_data,
                  :arlifile_path,
                  :config

    def initialize(config: Arli.config, libraries: [])
      self.config = config
      self.arlifile_path = "#{config.arlifile.path}/#{config.arlifile.name}"
      self.dependencies = read_dependencies(libraries)

      self.config.libraries.temp_dir ||= Dir.mktmpdir

      if parsed_data
        if parsed_data.libraries_path
          self.config.libraries.path = parsed_data.libraries_path
        end

        if parsed_data.lock_format
          Arli.config.arlifile.lock_format = parsed_data.lock_format
        end
      end
    end

    alias libraries dependencies

    def install
      each_in_temp_path do |lib|
        lib.install
      end
    end

    private

    def within_temp_path(&block)
      within_path(Arli.config.libraries.temp_dir, &block)
    end

    def each_in_temp_path(&block)
      within_temp_path do
        dependencies.each(&block)
      end
    end

    def within_path(p, &_block)
      FileUtils.mkpath(p) unless Dir.exist?(p)
      Dir.chdir(p) do
        yield if block_given?
      end
    end

    def read_dependencies(libraries)
      if libraries && !libraries.empty?
        libraries.map {|lib| make_lib(lib)}
      else
        unless arlifile_path && File.exist?(arlifile_path)
          raise(Arli::Errors::ArliFileNotFound,
                "Arlifile could not be found at\n#{arlifile_path.bold.yellow}")
        end
        parse_yaml_file
      end
    end

    def parse_yaml_file
      self.parsed_data = Hashie::Mash.new(
          Hashie::Extensions::SymbolizeKeys.symbolize_keys(
              ::YAML.load(
                  ::File.read(
                      self.arlifile_path)
              )
          )
      )
      parsed_data.dependencies.map {|lib| make_lib(lib)}
    end
  end
end
