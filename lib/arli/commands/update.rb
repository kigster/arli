require 'json'
require 'arli'
require 'net/http'
require_relative 'base'
require_relative '../installers/unzipper'

module Arli
  module Commands
    class Update < Base

      def initialize(options)
        super(options)
        self.arlifile = Arli::ArliFile.new(lib_path:      lib_path,
                                           arlifile_path: options[:arli_dir])
      end

      def run
        puts
        arlifile.each_dependency do |lib|
          info '...................................'.no_color
          info "Library: #{lib.name.bold.yellow}"

          backup_existing(lib)
          library = ::Arduino::Library::Resolver.resolve(lib)
          if library.nil?
            info "Could not find library matching #{lib.inspect}, skipping..."
            next
          elsif library.url.nil?
            info "Can't determine URL for library #{lib.inspect}, skipping"
            next
          else
            info "Version: #{library.version.bold.yellow}" if library.version
            if library.url =~ /\.zip$/i
              info 'downloading and unzipping file '.blue + "\n#{library.url.bold.magenta}"
              Arli::Installers::Unzipper.new(lib: library).install
            else
              c = git_command(library)
              execute(c)
            end
          end
        end
      end

      def backup_existing(lib)
        if Dir.exist?(lib.name)
          raise Arli::Errors::LibraryAlreadyExists, "Found library #{lib.name} in #{Dir.pwd}" if abort_if_exists
          backup_lib(lib)
        end
      end

      def git_command(lib)
        "cd #{lib.name} && git pull --rebase 2>&1"
      end

      def backup_lib_name(lib)
        "#{lib.name}.#{Time.now.strftime('%Y%m%d%H%M%S')}"
      end

      def backup_lib(lib)
        if File.exist?(lib.name)
          FileUtils.move(lib.name, backup_lib_name(lib))
          info "NOTE: backed up old version of #{lib.name.bold.yellow} to #{backup_lib_name(lib).bold.green}"
        end
      end


      protected

      # @param <String> *args — list of arguments or a single string
      def execute(*args)
        cmd = args.join(' ')
        raise 'No command to run was given' unless cmd
        info cmd.green
        o, e, s = Open3.capture3(cmd)
        puts o if o
        puts e.red if e
        s
      rescue Exception => e
        error "Error running [#{args.join(' ')}]\n" +
                "Current folder is [#{Dir.pwd.yellow}]", e
        raise e
      end

    end
  end
end
