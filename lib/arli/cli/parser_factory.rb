require_relative 'parser'

module Arli
  module CLI
    module ParserFactory

      class << self

        def default_help
          gp = global_parser
          gp.parse!(%w(--help))
          gp.print
        end

        def parse_argv(parser, argv)
          if parser
            parser.parse!(argv)
            parser.print
          end
        end

        def make_parser(command = nil, &block)
          ::Arli::CLI::Parser.new(command: command,
                                  config: Arli.config, &block)
        end

        def global_parser
          @global ||= make_parser do |parser|
            parser.banner = usage_line
            parser.sep
            parser.option_help(commands: true)
          end
        end

        def command_parsers
          @command_parsers ||= {
              install: {
                  description: 'installs libraries defined in Arlifile',
                  parser:      -> (command_name) {
                    make_parser(command_name) do |parser|
                      parser.banner = usage_line 'install'
                      parser.option_lib_home
                      parser.option_dependency_file
                      parser.option_abort_if_exists
                      parser.option_help(command_name: command_name)
                    end
                  } },

              search:  {
                  description: 'Flexible Search of the Arduino Library Database',
                  example:     'arli search '.green + %Q['name: /AudioZero/, version: "1.0.1"'].green,
                  parser:      -> (command_name) {
                    make_parser(command_name) do |parser|
                      parser.banner = usage_line 'search ' + '[ name-match | expression ]'.magenta
                      parser.option_search
                      parser.option_help(command_name: command_name)
                    end
                  }
              }
          }
        end

        def commands
          command_parsers.keys
        end

        def valid_command?(command)
          commands.include?(command)
        end

        def command_parser(cmd)
          cmd_hash = command_parsers[cmd]
          cmd_hash ? cmd_hash[:parser].call(cmd) : nil
        end

        def global_usage(command)
          "Usage:\n    " + Arli::Configuration::ARLI_COMMAND.blue +
              ' [ options ] '.yellow + '[ ' + (command || 'command').green +
              ' [ options ] '.yellow + ' ]' + "\n"
        end

        def command_usage(command)
          "Usage:\n    " + Arli::Configuration::ARLI_COMMAND.blue + ' ' +
              command.green +
              ' [options]'.yellow + "\n\n" +
              'Command Options'
        end

        def usage_line(command = nil)
          command ? command_usage(command) : global_usage(command)
        end
      end


    end
  end
end
