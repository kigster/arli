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
                                  config:  Arli.config, &block)
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
              search:  {
                  description: 'Search the Arduino Library Database (or a custom one)',
                  examples:    [
                                   { desc: 'Search using the regular expression containing the name:',
                                     cmd:  'arli search AudioZero' },

                                   { desc: 'Same exact search as above, but using ruby hash syntax:',
                                     cmd:  %Q{arli search 'name: /AudioZero/'} },

                                   { desc: 'Search using case insensitive name search, and :',
                                     cmd:  %Q{arli search 'name: /adafruit/i'} },

                                  { desc: 'Finally, search for the exact name match:',
                                     cmd:  %Q{arli search '^Time$'} },
                               ],

                  parser:      -> (command_name) {
                    make_parser(command_name) do |parser|
                      parser.banner = usage_line 'search ' + '[ name | search-expression ]'.magenta
                      parser.option_search
                      parser.option_help(command_name: command_name)
                    end
                  }
              },

              bundle: {
                  description: 'installs all libraries defined in the Arlifile',
                  examples:    [
                                   { desc: 'Install all libs defined in Arlifile:',
                                     cmd:  'arli bundle ' },

                                   { desc: 'Install all libs defined in src/Arlifile',
                                     cmd:  'arli bundle -a src ' }
                               ],

                  parser:      -> (command_name) {
                    make_parser(command_name) do |parser|
                      parser.banner = usage_line 'bundle'
                      parser.option_bundle
                      parser.option_help(command_name: command_name)
                    end
                  } },

              install: {
                  description: 'installs a single library',
                  examples:    [
                                   { desc: 'Install the latest version of this library',
                                     cmd:  'arli install "Adafruit GFX Library"' },

                                   { desc: 'Install the library from a Github URL',
                                     cmd:  'arli install https://github.com/jfturcot/SimpleTimer' },
                               ],

                  parser:      -> (command_name) {
                    make_parser(command_name) do |parser|
                      parser.banner = usage_line 'install' + ' [ "name" | [ git-url | zip-url ]'.magenta
                      parser.option_install
                      parser.option_help(command_name: command_name)
                    end
                  } },
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
          'Usage:'.magenta +
            "\n    " + arli_command + ' options '.yellow +
            "\n    " + arli_command + ' ' + ((command || 'command')).green + ' [ options ] '.yellow + "\n"
        end

        def arli_command
          @arli_command ||= Arli::Configuration::ARLI_COMMAND.blue.bold
        end

        def command_usage(command)
          'Usage:'.magenta +
              "\n    " + arli_command + ' ' + command.green + ' [options]'.yellow + "\n\n" +
              'Command Options'
        end

        def usage_line(command = nil)
          command ? command_usage(command) : global_usage(command)
        end
      end


    end
  end
end
