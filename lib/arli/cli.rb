require 'optparse'
require 'hashie/mash'
require 'hashie/extensions/symbolize_keys'
require 'colored2'
require 'arli'
require 'arli/parser'
require 'arli/commands/base'
require 'arli/commands/install'

module Arli
  class CLI
    class InvalidCommandError < ArgumentError;
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
        options.merge!(parser.options)
      end

      @options = Hashie::Extensions::SymbolizeKeys.symbolize_keys!(options.to_h)

      run_command! unless options[:help]

    rescue InvalidCommandError => e
      puts e.message
    end

    private

    def run_command!
      if command
        command_class       = ::Arli::Commands.const_get(command.to_s.capitalize)

        options[:arli_json] ||= ::Arli::DEFAULT_JSON_FILE
        options[:lib_home]  ||= ::Arli::DEFAULT_LIBRARY_PATH

        command_class.new(options).run
      end
    rescue NameError => e
      puts e.inspect
      puts "Unfortunately command #{command.to_s.red} is not yet implemented.\n\n"
    end

    def parse_command_options!
      self.class.parser_for(command)
    end

    def command_detected?
      self.command = argv.shift if argv.first && argv.first !~ /^-.*$/
      if self.command
        self.command = command.to_sym
        unless self.class.commands.key?(command)
          raise InvalidCommandError, "Error: #{command ? command.to_s.bold.red : 'nil'} is not a valid arli command!"
        end
      end
      self.command
    end

    class << self

      def global
        @global ||= PARSER.new do |parser|
          parser.banner = usage_line
          parser.sep
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
                parser.option_lib_home
                parser.option_dependency_file
                parser.option_help(command: command)
              end
            } },

          update:  {
            description: 'updates libraries defined in the JSON file',
            parser:      -> (command) {
              PARSER.new do |parser|
                parser.banner = usage_line 'update'
                parser.option_lib_home
                parser.option_dependency_file
                parser.option_help(command: command)
              end
            } },

          library: {
            description: 'Install, update, or remove a single library',
            parser:      -> (command) {
              PARSER.new do |parser|
                parser.banner = usage_line 'library'
                parser.option_lib_home
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
