require 'forwardable'
require 'arli'
require 'arli/actions'
require_relative 'single_version'

module Arli
  module Library
    class Installer
      include ::Arli::Helpers::Output

      extend Forwardable
      def_delegators :@library, :exists?

      attr_accessor :library, :config, :temp_dir

      def initialize(library, config: Arli.config)
        self.config   = config
        self.library  = library
        self.temp_dir = Arli.config.libraries.temp_dir
      end

      def install
        ___ "#{library.name.blue.bold} "
        if library.nil? && library.library.nil?
          ___ ' (no library) '
          fuck
        elsif library.url.nil?
          ___ ' (no url) '
          fuck
        else
          ___ "(#{library.version.yellow.bold}) " if library.version
          indent_cursor
          actions(library).each do |action|
            run_action(action)
          end
        end
        ___ "\n\n"
      end

      def run_action(action_name)
        klass = Arli::Actions.action(action_name)
        if klass
          action = klass.new(library, config: config)
          if action.supported?
            print_action_starting(action_name.to_s) do
              action.run!
            end
            puts if verbose?
          else
            print_action_failure('unsupported', "missing pre-requisites: #{klass.command_name.bold.yellow} did not succeed")
          end
        else
          print_action_failure("#{action_name.red} not found")
        end
      end

      def verbose?
        config.verbose
      end

      def actions(library)
        actions = []
        # First, how do we get the library?
        actions << ((library.url =~ /\.zip$/i) ? :unzip_file : :git_repo)
        actions << :dir_name
        actions << :move_to_library_path
        actions.flatten
      end
    end
  end
end
