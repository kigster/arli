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
            parser.option_search_attributes
            parser.option_help(commands: true)
          end
        end

        def command_parsers
          @command_parsers ||= {
              search:  Hashie::Mash.new(
                  {
                      sentence:    'Search standard Arduino Library Database with over 4K entries ',
                      description: %Q[This command provides both the simple name-based search interface,
                                    and the most sophisticated attribute-specific search using a downloaded, 
                                    and locally cached Public Arduino Database JSON file, maintained 
                                    by the Arduino Community. If you know of another database, 
                                    that's what the #{'--database'.blue} flag is for.
                                    Note that you can print the list of available attributes by 
                                    running arli with #{'--print-attrs'.blue} flag.
                                    ],
                      examples:    [
                                       { desc: 'Finds any library with name matching a given string, case insensitively',
                                         cmd:  'arli search audiozero' },

                                       { desc: 'If the first character is "/", then the argument is assumed to be regex',
                                         cmd:  %Q{arli search /AudioZero$/  } },

                                       { desc: 'If the first character is "=", then the rest is assumed to be exact name',
                                         cmd:  %Q{arli search =Time  } },

                                       { desc: 'Lets get a particular version of the library using another attribute',
                                         cmd:  %Q{arli search 'name: "AudioZero", version: "1.0.2"'} },

                                       { desc: 'Search using case insensitive search for the author',
                                         cmd:  %Q{arli search 'author: /adafruit/i'} },

                                       { desc: 'Finally, search for regex match for "WiFi" in a sentence or a paragraph',
                                         cmd:  %Q{arli search 'sentence: /wifi/i, paragraph: /wifi/i'} },
                                   ],

                      parser:      -> (command_name) {
                        make_parser(command_name) do |parser|
                          parser.banner = usage_line 'search ' + '[ -A | search-expression ] '.magenta
                          parser.option_search
                          parser.option_help(command_name: command_name)
                        end
                      }
                  }),

              bundle:  Hashie::Mash.new(
                  {
                      sentence: 'Installs all libraries specified in Arlifile',
                      description: %Q[This command reads #{'Arlifile'.bold.green} (from the current folder, by default),
                                    and then it installs all dependent libraries specified there, checking if
                                    each already exists, and if not — downloading them, and installing them into
                                    your Arduino Library folder. Both the folder with the Arlifile, as well as the
                                    destination library path folder can be changed with the command line flags.
                                ],
                      example: [
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
                      description: %Q[This command installs a single library into your library path
                                       (which can be set with #{'--lib-path'.blue} flag).
                                       Arli interpretes the third argument to #{'arli install'.bold.blue}
                                       as either an exact library name, or a remote URL
                                       (either ZIP or Git Repo). You can use #{'search'.bold.green} command
                                       to first find the right library name, and then pass it to the install command.
                                   ],
                      examples:    [
                                       { desc: 'Install the latest version of this library locally',
                                         cmd:  'arli install "Adafruit GFX Library" -l ./libraries' },

                                       { desc: 'Install the library from a Github URL',
                                         cmd:  'arli install https://github.com/jfturcot/SimpleTimer' }
                                   ],

                      parser:      -> (command_name) {
                        make_parser(command_name) do |parser|
                          parser.banner = usage_line 'install' + ' [ "Exact Library Name" | url ] '.magenta
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
