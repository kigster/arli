require_relative 'action'
module Arli
  module Actions
    class GitRepo < Action
      description 'Fetches or updates remote git repositories'
      check_command 'git --version'
      check_pattern 'git version'

      def execute
        c      = library.exists? ? git_update_command : git_clone_command
        action = library.exists? ? 'updated' : 'cloned'
        run_system_command(c)
        print_action_success(action, "git repo was #{action}")
      end

      def git_update_command
        "cd #{library.path} && git pull --rebase 2>&1"
      end

      def git_clone_command
        "git clone -v #{library.url} #{library.dir} 2>&1"
      end

      protected

      # @param <String> *args — list of arguments or a single string
      def run_system_command(*args)
        cmd = args.join(' ')
        raise 'No command to run was given' unless cmd
        info("\n" + cmd.green) if Arli.debug?
        o, e, s = Open3.capture3(cmd)
        info("\n" + o) if o if Arli.debug?
        info("\n" + e.red) if e && Arli.debug?
      rescue Exception => e
        error "Error running [#{args.join(' ')}]\n" +
                  "Current folder is [#{Dir.pwd.yellow}]", e
        raise e
      end
    end
  end
end
