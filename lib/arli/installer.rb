require 'arli'
require_relative 'output'
require_relative 'installers/git_repo'
require_relative 'installers/zip_file'
require_relative 'installers/backup'

module Arli
  class Installer
    include ::Arli::Output

    attr_accessor :lib, :lib_dir, :lib_path, :command

    def initialize(lib:, command:, lib_path: Arli.library_path)
      self.lib      = lib
      self.command  = command
      self.lib_dir  = lib.name.gsub(/ /, '_')
      self.lib_path = lib_path
    end

    def install
      Arli::Installers::Backup.new(lib: lib, lib_path: lib_path).backup! if command.create_backup
      abort! if exists? && command.abort_if_exists

      action = self.exists? ? 'updating' : 'installing'
      s "#{action} #{lib.name.blue}"

      library = ::Arduino::Library::Resolver.resolve(lib)

      if library.nil?
        print_failure
      elsif library.url.nil?
        print_failure
      else
        s "(#{library.version.blue})" if library.version
        print_success
        if library.url =~ /\.zip$/i
          Arli::Installers::ZipFile.new(lib: library, lib_path: lib_path).install
        else
          Arli::Installers::GitRepo.new(lib: library, lib_path: lib_path).install
        end
      end
      s nil, true
    end

    def exists?
      Dir.exist?(target_lib_path)
    end

    def target_lib_path
      "#{lib_path}/#{lib_dir}"
    end

    def abort!
      raise Arli::Errors::LibraryAlreadyExists,
            "Library #{target_lib_path} already exists!"
    end

  end
end

