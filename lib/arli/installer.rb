require 'arli'
require 'forwardable'
module Arli
  class Installer
    extend Forwardable
    attr_accessor :lib, :lib_dir, :lib_path, :command

    def_delegators :@command, :info, :error, :debug

    def initialize(lib:, command:, lib_path: Arli.library_path)
      self.lib      = lib
      self.command  = command
      self.lib_dir  = lib.name.gsub(/ /, '_')
      self.lib_path = lib_path
    end

    def exists?
      Dir.exist?(target_lib_path)
    end

    def install
      action = self.exists? ? 'replacing' : 'installing'
      backup! if command.create_backup
      abort! if exists? && command.abort_if_exists

      s "#{action} #{lib.name.blue}"
      library = ::Arduino::Library::Resolver.resolve(lib)

      if library.nil?
        s ' ❌ ' + "\n"
      elsif library.url.nil?
        s ' ❌ ' + "\n"
      else
        s "(#{library.version.blue})" if library.version
        s '✔ '.bold.green
        if library.url =~ /\.zip$/i
          s 'unpacking zip...'
          Arli::Installers::ZipFile.new(lib: library).install
          s '✔ '.bold.green
        else
          c = exists? ? git_update_command : git_clone_command
          s 'running git...'
          execute(c)
          s '✔ '.bold.green
        end
      end
      s nil, true
    end


    def git_update_command
      "cd #{lib_dir} && git pull --rebase 2>&1"
    end

    def git_clone_command
      "git clone -v #{lib.url} #{lib_dir} 2>&1"
    end

    def backup_lib_path
      target_lib_path + ".#{Time.now.strftime('%Y%m%d%H%M%S')}"
    end

    def target_lib_path
      "#{lib_path}/#{lib_dir}"
    end

    def backup!
      FileUtils.cp_r(target_lib_path, backup_lib_path) if exists?
    end

    def abort!
      raise Arli::Errors::LibraryAlreadyExists,
            "Library #{target_lib_path} already exists!"
    end

    def s(msg, newline = false)
      printf msg + ' ' if msg
      puts if newline
    end

    protected

    # @param <String> *args — list of arguments or a single string
    def execute(*args)
      cmd = args.join(' ')
      raise 'No command to run was given' unless cmd
      info("\n" + cmd.green) if self.debug
      o, e, s = Open3.capture3(cmd)
      info("\n" + o) if o if self.debug
      info("\n" + e.red) if e && self.debug
      s
    rescue Exception => e
      error "Error running [#{args.join(' ')}]\n" +
              "Current folder is [#{Dir.pwd.yellow}]", e
      raise e
    end

  end
end

