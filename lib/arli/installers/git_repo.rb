require_relative 'base'
module Arli
  module Installers
    class GitRepo < ::Arli::Installers::Base

      def install
        c = exists? ? git_update_command : git_clone_command
        s 'running git...'
        execute(c)
        super
      end

      def git_update_command
        "cd #{lib_dir} && git pull --rebase 2>&1"
      end

      def git_clone_command
        "git clone -v #{lib.url} #{lib_dir} 2>&1"
      end

      protected

      # @param <String> *args — list of arguments or a single string
      def execute(*args)
        cmd = args.join(' ')
        raise 'No command to run was given' unless cmd
        info("\n" + cmd.green) if Arli.debug?
        o, e, s = Open3.capture3(cmd)
        info("\n" + o) if o if Arli.debug?
        info("\n" + e.red) if e && Arli.debug?
        s
      rescue Exception => e
        error "Error running [#{args.join(' ')}]\n" +
                "Current folder is [#{Dir.pwd.yellow}]", e
        raise e
      end


    end
  end
end
