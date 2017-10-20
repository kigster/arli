require 'optparse'
require 'hashie/mash'
require 'colored2'

module Arli

  class CLI
    DEFAULT_JSON_FILE = 'arli.json'.freeze

    class InvalidCommandError < ArgumentError
    end

    class Parser < OptionParser
      attr_accessor :output_lines, :command

      def initialize(command = nil)
        super
        self.output_lines = Array.new
        self.command      = command
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

    COMMAND = 'arli'
    PARSER  = ::Arli::CLI::Parser

    attr_accessor :argv, :command, :parser
    attr_accessor :options

    def initialize(argv = ARGV.dup)
      self.argv    = argv
      self.options = Hashie::Mash.new
    end

    def parse
      if argv.first
        if argv.first =~ /^-.*$/
          self.parser = self.class.global
        elsif command_detected?
          self.parser = parse_command_options!
        end
      end

      if parser
        parser.parse!(argv)
        parser.print
      end

    end

    private

    def parse_command_options!
      self.class.parser_for(command)
    end

    def command_detected?
      self.command = argv.shift if argv.first && argv.first !~ /^-.*$/

      if self.command
        self.command = command.to_sym
        unless self.class.commands.key?(command)
          raise InvalidCommandError, "Error: #{command ? command.to_s.bold.red : 'nil'} is not a valid command"
        end
      end

      self.command
    end

    class << self

      def global
        @global ||= PARSER.new do |parser|
          parser.banner = usage_line
          parser.sep
          parser.option_lib_home
          parser.option_help(commands: true)
        end
      end

      def usage_line(command = nil)
        command ? command_usage(command) : global_usage(command)
      end

      def global_usage(command)
        "Usage:\n    ".bold + COMMAND.bold.blue + ' ' + '[options] '.yellow + '[' + (command || 'command').green + ' [options]'.yellow + ']' + "\n"
      end

      def command_usage(command)
        "Usage:\n    ".bold + COMMAND.bold.blue + ' ' + command.bold.green + ' [options]'.yellow + "\n\n" + 'Command Options'.bold
      end

      def commands
        @commands ||= {
          install: {
            description: 'installs libraries defined in the JSON file',
            parser:      -> (command) {
              PARSER.new do |parser|
                parser.banner = usage_line 'install'
                parser.option_dependency_file
                parser.option_help(command: command)
              end
            } },

          update:  {
            description: 'updates libraries defined in the JSON file',
            parser:      -> (command) {
              PARSER.new do |parser|
                parser.banner = usage_line 'update'
                parser.option_dependency_file
                parser.option_help(command: command)
              end
            } },

          library: {
            description: 'Install, update, or remove a single library',
            parser:      -> (command) {
              PARSER.new do |parser|
                parser.banner = usage_line 'library'
                parser.option_library
                parser.option_help(command: command)
              end
            } }
        }
      end

      def parser_for(cmd)
        if commands[cmd]
          cmd_hash = commands[cmd]
          commands[cmd][:parser][cmd_hash]
        else
          raise(InvalidCommandError, "'#{cmd}' is not a valid command.\nSupported commands are:\n\t#{commands.keys.join("\n\t")}")
        end
      end
    end
  end
end
