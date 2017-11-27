require 'forwardable'
require 'optparse'
require 'colored2'

require_relative 'parser'
require_relative 'command_finder'
require_relative 'parser_factory'
require_relative '../commands'
require_relative '../output'


module Arli
  module CLI
    class App
      include Arli::Output

      attr_accessor :argv, :config, :command

      def initialize(argv, config: Arli.config)
        self.argv                = argv
        self.config              = config
        self.config.runtime.argv = argv
      end

      def start
        if argv.empty?
          factory.default_help
          return
        end

        parse_global_flags
        return if Arli.config.help

        finder = CommandFinder.new(argv, config: config)
        finder.parse!
        return if Arli.config.help

        if finder.command
          self.command = finder.command
          execute!
        else
          factory.default_help
        end
      rescue OptionParser::InvalidOption => e
        report_exception(e, 'Invalid flags or options')
      rescue Arli::Errors::InvalidCommandError => e
        report_exception(e, 'Unknown command')
      rescue Exception => e
        report_exception(e)
      end

      def parse_global_flags
        if argv.first && argv.first.start_with?('-')
          parser = factory.global_parser
          factory.parse_argv(parser, argv)
        end
      end

      def execute!
        if command
          header(command: command) if config.verbose
          command.run
        else
          factory.default_help
        end
      end

      def factory
        Arli::CLI::ParserFactory
      end
    end
  end
end
