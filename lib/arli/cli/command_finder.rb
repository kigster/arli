require 'forwardable'
require 'optparse'

require 'colored2'

require_relative 'parser'
require_relative 'parser_factory'
require_relative '../commands'
require_relative '../commands/search'
require_relative '../commands/install'
require_relative '../output'

module Arli
  module CLI
    class CommandFinder

      include Arli::Output

      attr_accessor :argv, :config, :command_name, :command

      def initialize(argv, config: Arli.config)
        self.config = config
        self.argv   = argv
      end

      def parse!
        begin
          self.command_name = detect_command
          parse_command_arguments!(command_name)
          unless Arli.config.help
            self.command = instantiate_command
            if self.command
              config.runtime.command.instance = command
              config.runtime.command.name     = command_name
            end
          end
          self
        rescue Exception => e
          error(e)
          self.command = nil
          Arli.config.help =  true
        end
      end

      def parse_command_arguments!(cmd)
        parser = factory.command_parser(cmd)
        if parser
          factory.parse_argv(parser, argv)
        end
      end

      def instantiate_command
        self.command_name = detect_command unless command_name
        begin
          name          = command_name.to_s.capitalize.to_sym
          command_class = ::Arli::Commands.const_get(name)
          raise_invalid_arli_command!(command_name) unless command_class
          command_class.new(config: config) if command_class
        end
      end

      def detect_command
        return nil unless argv.first && argv.first !~ /^-.*$/
        cmd = argv.shift.to_sym
        if factory.valid_command?(cmd)
          cmd
        else
          raise_invalid_arli_command!(cmd)
        end
      end

      def factory
        Arli::CLI::ParserFactory
      end
    end

  end
end
