require 'optparse'
require 'hashie/mash'
require 'hashie/extensions/symbolize_keys'
require 'colored2'
require 'arli'
require 'arli/parser'
require 'arli/commands/update'
require 'arli/commands/install'
require 'arli/commands/search'

module Arli
  class CLI

    COMMAND = 'arli'.freeze
    PARSER  = ::Arli::CLI::Parser

    attr_accessor :argv, :parser, :command_name, :command
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

      self.options = Hashie::Extensions::SymbolizeKeys.symbolize_keys!(options.to_h)

      unless options[:help]
        self.command = create_command if command_name
        execute
      end

    rescue OptionParser::InvalidOption => e
      report_exception(e, 'Command line usage error!')

    rescue Arli::Errors::InvalidCommandError
      report_exception(e, 'This command does not exist')

    rescue Exception => e
      report_exception(e, 'Error')
      raise e if options[:trace]
    end

    private

    def report_exception(e, header = nil)
      error header if header
      printf ' ↳ '
      error e.message if e && e.respond_to?(:message)
    end

    def execute
      if command
        command.header if command.respond_to?(:header)
        command.run
      else
        gp = self.class.global
        gp.parse!(%w(--help))
        gp.print
        nil
      end
    rescue NameError => e
      error e.inspect
      error e.backtrace.join("\n") if options[:trace]
    end

    def create_command
      command_class = ::Arli::Commands.const_get(command_name.to_s.capitalize)

      options[:lib_home] ||= ::Arli.config.library_path
      options[:argv]     = argv

      info "created command #{command_name.to_s.green},\noptions: #{options.inspect.blue}" if Arli.debug?

      command_class.new(options)
    end

    private

    def info(*args)
      self.class.output(*args)
    end

    def error(*args)
      self.class.output(*(args.compact.map { |a| a.to_s.red }))
    end

    def parse_command_options!
      self.class.parser_for(command_name)
    end

    def command_detected?
      self.command_name = argv.shift if argv.first && argv.first !~ /^-.*$/
      if self.command_name
        self.command_name = command_name.to_sym
        unless self.class.commands.key?(command_name)
          raise Arli::Errors::InvalidCommandError, "Error: #{command_name ? command_name.to_s.red : 'nil'} is not a valid arli command_name!"
        end
      end
      self.command_name
    end

    class << self

      def output(*args)
        puts args.join("\n") unless args.empty?
      end

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
        "Usage:\n    " + COMMAND.blue +
          ' [options] '.yellow + '[ ' + (command || 'command').green +
          ' [options] '.yellow + ' ]' + "\n"
      end

      def command_usage(command)
        "Usage:\n    " + COMMAND.blue + ' ' +
          command.green +
          ' [options]'.yellow + "\n\n" +
          'Command Options'
      end

      def commands
        @commands ||= {
          install: {
            description: 'installs libraries defined in Arlifile',
            parser:      -> (command_name) {
              PARSER.new do |parser|
                parser.banner = usage_line 'install'
                parser.option_lib_home
                parser.option_dependency_file
                parser.option_abort_if_exists
                parser.option_help(command_name: command_name)
              end
            } },

          update:  {
            description: 'updates libraries defined in the Arlifile',
            parser:      -> (command_name) {
              PARSER.new do |parser|
                parser.banner = usage_line 'update'
                parser.option_lib_home
                parser.option_dependency_file
                parser.option_help(command_name: command_name)
              end
            } },

          search:  {
            description: 'Flexible Search of the Arduino Library Database',
            example:     'arli search '.green + %Q['name: /AudioZero/, version: "1.0.1"'].green,
            parser:      -> (command_name) {
              PARSER.new do |parser|
                parser.banner = usage_line 'search ' + '<query>'.magenta
                parser.option_search
                parser.option_help(command_name: command_name)
              end
            }
          }
        }
      end

      def parser_for(cmd)
        if commands[cmd]
          cmd_hash = commands[cmd]
          commands[cmd][:parser][cmd_hash]
        else
          raise(Arli::Errors::InvalidCommandError,
                "'#{cmd}' is not a valid command_name.\nSupported commands are:\n\t#{commands.keys.join("\n\t")}")
        end
      end
    end
  end
end
