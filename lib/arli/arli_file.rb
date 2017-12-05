require 'arli'
require 'yaml'
require 'forwardable'
require 'arduino/library'
require 'hashie/mash'

module Arli
  class ArliFile
    require 'arduino/library/include'

    include Enumerable
    extend Forwardable

    def_delegators :@dependencies, *(Array.new.methods - Object.methods)

    attr_accessor :dependencies,
                  :parsed_data,
                  :arlifile_path

    def initialize(config: Arli.config, libraries: [])
      self.arlifile_path             = "#{config.arlifile.path}/#{config.arlifile.name}"
      self.dependencies              = read_dependencies(libraries)
      Arli.config.libraries.temp_dir ||= Dir.mktmpdir
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


    def library_model(lib)
      return lib if lib.is_a?(::Arduino::Library::Model)
      ::Arduino::Library::Model.from(lib).tap do |model|
        if model.nil?
          lib_output = (lib && lib['name']) ? lib['name'] : lib.to_s
          raise Arli::Errors::LibraryNotFound, 'Error: '.bold.red +
              "Library #{lib_output.yellow} ".red + "was not found.\n\n".red +
              %Q[  HINT: run #{"arli search 'name: /#{lib_output}/'".green}\n] +
              %Q[        to find the exact name of the library you are trying\n] +
              %Q[        to install. Alternatively, provide a url: field.\n]
        end
      end
    end

    def make_lib(lib)
      ::Arli::Library::SingleVersion.new(library_model(lib))
    end

    def within_path(p, &_block)
      FileUtils.mkpath(p) unless Dir.exist?(p)
      Dir.chdir(p) do
        yield if block_given?
      end
    end

    def read_dependencies(libraries)
      if libraries && !libraries.empty?
        libraries.map { |lib| make_lib(lib) }
      else
        unless arlifile_path && File.exist?(arlifile_path)
          raise(Arli::Errors::ArliFileNotFound,
                "Arlifile could not be found at\n#{arlifile_path.bold.yellow}")
        end
        parse_yaml_file
      end
    end

    def parse_yaml_file
      self.parsed_data = Hashie::Mash.new(::YAML.load(::File.read(self.arlifile_path)))
      parsed_data.dependencies.map { |lib| make_lib(lib) }
    end
  end
end
