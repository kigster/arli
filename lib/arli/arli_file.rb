require 'arli'
require 'arduino/library'
require 'yaml'
require 'forwardable'

module Arli
  class ArliFile
    require 'arduino/library/include'

    include Enumerable

    extend Forwardable
    def_delegators :@dependencies, *(Array.new.methods - Object.methods)

    attr_accessor :dependencies, :file_hash, :file, :lib_path, :resolved

    def initialize(custom_file_path = nil,
                   lib_path = Arli.config.library.path)

      self.lib_path = lib_path
      self.file     = if custom_file_path
                        if ::Dir.exist?(custom_file_path)
                          Arli::File::Finder.default_arli_file(custom_file_path)
                        elsif  ::File.exist?(custom_file_path)
                          custom_file_path
                        end
                      end
      self.file     ||= Arli::File::Finder.default_arli_file
      self.dependencies = []
      raise(Arli::Errors::ArliFileNotFound, 'Arlifile could not be found') unless file

      parse!
    end

    def parse!
      begin
        self.file_hash = ::YAML.load(::File.read(self.file))
        self.dependencies = file_hash['dependencies'].map do |lib|
          Arduino::Library::Model.from_hash(lib)
        end
      rescue Exception => e
        error "Error parsing YAML file #{file}:\n#{e.message}"
        raise e
      end
    end

    def libraries
      self.dependencies
    end

    def all_dependencies(cmd)
      method_name = :run_dependency

      for_each_dependency do |dep|
        begin
          argv = args.map { |key| dep[key] }
          if self.respond_to?(method_name)
            info("dependency #{dep.inspect}: calling #{method_name} with args #{argv.inspect}")

            self.send(method_name, *argv) do |system_command|
              puts "execute(#{system_command})"
            end
          else
            raise ArgumentError,
                  "Method #{method_name.to_s.blue} is not implemented on #{self.class.name.red}"
          end
        end
      end
    rescue Exception => e
      error "Error while running command #{cmd}:\n\n#{e.message.red}"
      error e.backtrace.join("\n")
    end

    def within_lib_path
      FileUtils.mkpath(lib_path) unless Dir.exist?(lib_path)
      Dir.chdir(lib_path) do
        yield if block_given?
      end
    end

    def for_each_dependency(&_block)
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
  end
end
