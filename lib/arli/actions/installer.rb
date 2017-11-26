require 'arli'
require_relative '../output'
require_relative 'git_repo'
require_relative 'zip_file'
require_relative 'backup'
require_relative 'dir_name'

module Arli
  module Actions
    class Installer
      include ::Arli::Output

      attr_accessor :lib, :config, :command

      def initialize(lib, command, config: Arli.config)
        self.config       = config
        self.command      = command
        self.lib          = lib
      end

      def library_path
        config.libraries.path
      end

      def exists?
        Dir.exist?(target_library_path)
      end

      def lib_dir
        lib.name.gsub(/ /, '_')
      end

      def target_library_path
        "#{library_path}/#{lib_dir}"
      end

      def cfg
        config.install
      end

      def install
        if exists?
          if cfg.if_exists.abort
            abort!
          elsif cfg.if_exists.backup
            Arli::Actions::Backup.new(path).backup!
          end

          action = self.exists? ? 'updating' : 'installing'
          ___ "#{action} #{lib.name.blue}"

          library = ::Arduino::Library::Resolver.resolve(lib)

          if library.nil?
            print_failure
          elsif library.url.nil?
            print_failure
          else
            ___ "(#{library.version.blue})" if library.version
            print_success
            if library.url =~ /\.zip$/i
              Arli::Actions::ZipFile.new(lib: library, library_path: library_path).install
            else
              Arli::Actions::GitRepo.new(lib: library, library_path: library_path).install
            end
          end

          dn = Arli::Actions::DirName.new(lib: library, library_path: library_path)
          dn.install
          self.lib_dir = dn.lib_dir
          ___ nil, true
        end

        def abort!
          raise Arli::Errors::LibraryAlreadyExists,
                "Library #{target_library_path} already exists!"
        end

      end
    end
  end
end

