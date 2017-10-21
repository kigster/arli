module Arli
  class CLI
    class Parser < OptionParser
      attr_accessor :output_lines, :command, :options

      def initialize(command = nil)
        super
        self.output_lines = Array.new
        self.command      = command
        self.options = Hashie::Mash.new

      end

      def sep(text = nil)
        separator text || ''
      end

      def option_dependency_file
        on('-a FILE', '--arli-json FILE', "JSON file with dependencies (defaults to #{DEFAULT_JSON_FILE.bold.magenta})") { |v| options[:arli_json] = v }
      end

      def option_help(commands: false, command: nil)
        on('-h', '--help', 'prints this help') do
          puts 'Description:'.bold if command
          output ' ' * 4 + command[:description].bold.green if command
          output ''
          output_help
          output_command_help if commands
          options[:help] = true
        end
      end

      def option_lib_home
        on('-L', '--lib-home HOME', 'Specify a local directory where libraries are installed') { |v| options[:lib_home] = v }
      end

      def option_library
        on('-l', '--lib LIBRARY', 'Library Name') { |v| options[:library_name] = v }
        on('-f', '--from FROM', 'A git or https URL') { |v| options[:library_from] = v }
        on('-v', '--version VERSION', 'Library Version, i.e. git tag') { |v| options[:library_version] = v }
        on('-i', '--install', 'Install a library') { |v| options[:library_action] = :install }
        on('-r', '--remove', 'Remove a library') { |v| options[:library_action] = :remove }
        on('-u', '--update', 'Update a local library') { |v| options[:library_action] = :update }
      end

      def option_help_with_subtext
        option_help
      end

      def output_help
        output self.to_s
      end

      def output_command_help
        output command_help
      end

      def command_help
        subtext = "  Available Commands:\n"

        ::Arli::CLI.commands.each_pair do |command, config|
          subtext << <<-EOS
#{sprintf('    %-12s', command.to_s).green} : #{sprintf('%-70s', config[:description]).yellow}
          EOS
        end
        subtext << <<-EOS
        
See #{COMMAND.bold.blue + ' <command> '.bold.green + '--help'.bold.yellow} for more information on a specific command.

        EOS
        subtext
      end

      def output(value = nil)
        self.output_lines << value if value
        self.output_lines
      end

      def print
        puts output.join("\n")
      end
    end
  end
end
