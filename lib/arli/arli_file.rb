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
                  :arlifile_hash,
                  :arlifile_path,
                  :config,
                  :device

    def initialize(config: Arli.config, libraries: [])
      self.config = config
      self.arlifile_path = "#{config.arlifile.path}/#{config.arlifile.name}"
      self.dependencies = read_dependencies(libraries)

      self.config.libraries.temp_dir ||= Dir.mktmpdir

      configure_via_arlifile!(arlifile_hash)
    end

    alias libraries dependencies

    def install
      each_in_temp_path do |lib|
        lib.install
      end
    end

    private

    def configure_via_arlifile!(mash)
      if mash
        config.libraries.path = mash.libraries_path if mash.libraries_path
        config.arlifile.lock_format = mash.lock_format if mash.lock_format
        self.device = mash.device if mash.device
      end
    end

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
      self.arlifile_hash = Hashie::Mash.new(
          Hashie::Extensions::SymbolizeKeys.symbolize_keys(
              ::YAML.load(
                  ::File.read(self.arlifile_path)
              )
          )
      )

      config.arlifile.hash = arlifile_hash

      arlifile_hash.dependencies.map {|lib| make_lib(lib)}
    end
  end
end
