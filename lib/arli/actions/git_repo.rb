require_relative 'action'
require_relative '../helpers/system_commands'

module Arli
  module Actions
    class GitRepo < Action

      include ::Arli::Helpers::SystemCommands

      description 'Fetches or updates remote git repositories'
      check_command 'git --version'
      check_pattern 'git version'

      def execute
        run_system_command(git_clone_command)
        print_action_success('cloned', "cloned from #{library.url}")
      end

      def git_update_command
        "cd #{library.path} && git pull --rebase 2>&1"
      end

      def git_clone_command
        "git clone -v #{library.url} #{library.dir} 2>&1"
      end

    end
  end
end
