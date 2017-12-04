require_relative 'parser'

module Arli
  module CLI
    module ParserFactory

      class << self

        def default_help
          gp = global_parser
          gp.parse!(%w(--help))
          print_parser_help(gp)
        end

        def parse_argv(parser, argv)
          if parser
            parser.parse!(argv)
            print_parser_help(parser)
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
              search:  Hashie::Mash.new(
                  {
                      sentence:    'Search standard Arduino Library Database with over 4K entries',
                      description: ["This command provides both the simple name-based search interface,\n",
                                    "and the most sophisticated field-by-field search using a downloaded, \n",
                                    "and locally cached Public Arduino Database JSON file, maintained\n",
                                    "by Arduino and the Community. If you know of another database,\n",
                                    "that's what the --database flag is for."],
                      examples:    [
                                       { desc: 'Search using the regular expression containing the name:',
                                         cmd:  'arli search AudioZero' },

                                       { desc: 'Same exact search as above, but using ruby hash syntax:',
                                         cmd:  %Q{arli search 'name: /AudioZero/'} },

                                       { desc: 'Lets get a particular version of the library',
                                         cmd:  %Q{arli search 'name: "AudioZero", version: "1.0,2"'} },

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
                  }),

              bundle:  Hashie::Mash.new(
                  {
                      sentence: 'Installs all libraries specified in Arlifile',
                      description:
                                [
                                    "This command reads ", "Arlifile".bold.green, " (from the current folder, by default),\n",
                                    "and then it installs all dependent libraries specified there, checking if \n",
                                    "each already exists, and if not —  downloading them, and installing them into\n",
                                    "your Arduino Library folder. Both the folder with the Arlifile, as well as the\n",
                                    "destination library path folder can be changed with the command line flags.\n",
                                ],
                      examples: [
                                    { desc: 'Install all libs defined in Arlifile:',
                                      cmd:  'arli bundle ' },

                                    { desc: 'Custom Arlifile location, and destination path:',
                                      cmd:  'arli bundle -a ./src -l ./libraries' }
                                ],

                      parser:   -> (command_name) {
                        make_parser(command_name) do |parser|
                          parser.banner = usage_line 'bundle'
                          parser.option_bundle
                          parser.option_help(command_name: command_name)
                        end
                      } }),

              install: Hashie::Mash.new(
                  {
                      sentence:    'Installs a single library either by searching, or url or local ZIP',
                      description: [
                                       "This command installs a single library into your library path\n",
                                       "using the third argument to the command #{'arli install'.bold.white}\n".dark ,
                                       "which can be a library name, local ZIP file, or a remote URL \n",
                                       "(either ZIP or Git Repo)\n"

                                   ],
                      examples:    [
                                       { desc: 'Install the latest version of this library',
                                         cmd:  'arli install "Adafruit GFX Library"' },

                                       { desc: 'Install the library from a Github URL',
                                         cmd:  'arli install https://github.com/jfturcot/SimpleTimer' },

                                       { desc: 'Install a local ZIP file',
                                         cmd:  'arli install ~/Downloads/DHT-Library.zip' },
                                   ],

                      parser:      -> (command_name) {
                        make_parser(command_name) do |parser|
                          parser.banner = usage_line 'install' + ' [ "library name" | url | local-zip ] '.magenta
                          parser.option_install
                          parser.option_help(command_name: command_name)
                        end
                      } }),
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
          'Usage:'.magenta.bold +
              "\n    " + arli_command + ' options '.yellow +
              "\n    " + arli_command + ' ' + ((command || 'command')).green + ' [ options ] '.yellow + "\n"
        end

        def arli_command
          @arli_command ||= Arli::Configuration::ARLI_COMMAND.blue.bold
        end

        def command_usage(command)
          'Usage:'.magenta.bold +
              "\n    " + arli_command + ' ' + command.green + ' [options]'.yellow + "\n\n" +
              'Options'.magenta.bold
        end

        def usage_line(command = nil)
          command ? command_usage(command) : global_usage(command)
        end

        def print_parser_help(parser)
          parser.print
        end
      end


    end
  end
end
