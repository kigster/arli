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
                                  config: Arli.config, &block)
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
            search: Hashie::Mash.new(
              sentence: 'Search standard Arduino Library Database with over 4K entries ',
              description: %[This command provides both the simple name-based search interface,
                                and the most sophisticated attribute-specific search using a downloaded,
                                and locally cached Public Arduino Database JSON file, maintained
                                by the Arduino Community. If you know of another database,
                                that's what the #{'--database'.blue} flag is for.
                                Note that you can print the list of available attributes by
                                running arli with #{'--print-attrs'.blue} flag.
                                ],
              examples: [
                { desc: 'Finds any library with name matching a given string, case insensitively',
                  cmd: 'arli search audiozero' },

                { desc: 'If the first character is "/", then the argument is assumed to be regex',
                  cmd: 'arli search /AudioZero$/  ' },

                { desc: 'If the first character is "=", then the rest is assumed to be exact name',
                  cmd: 'arli search =Time  ' },

                { desc: 'Lets get a particular version of the library using another attribute',
                  cmd: 'arli search \'name: "AudioZero", version: "1.0.2"\'' },

                { desc: 'Search using case insensitive search for the author',
                  cmd: 'arli search \'author: /adafruit/i\'' },

                { desc: 'Finally, search for regex match for "WiFi" in a sentence or a paragraph',
                  cmd: 'arli search \'sentence: /wifi/i, paragraph: /wifi/i\'' },
              ],

              parser: ->(command_name) {
                        make_parser(command_name) do |parser|
                          parser.banner = usage_line 'search ' + '[ -A | search-expression ] '.magenta
                          parser.option_search
                          parser.option_help(command_name: command_name)
                        end
                      }
            ),

            generate: Hashie::Mash.new(
              sentence: 'Generates a new Arduino project with Arlifile',

              description: 'This will create a new project folder, a source file, and an Arlifile
                                based on the template project repo defined in the config file. At the moment
                                only arduino-cmake is supported as the build environment as it\'s the one that
                                provides the widest choice of developer IDEs to use for programming your project.
                                You can use Vim or Emacs, Atom, CLion, Eclipse, Visual Studio, or just plain
                                command line to build and upload your project. Some knowledge of CMake is
                                helpful.
                              ',
              examples: [
                { desc: 'Creates a new project in the specified folder. Default is current dir.',
                  cmd: 'arli generate MyClock --workspace ~/Documents/Arduino/Sketches' },

                { desc: 'Creates a folder "Blinker" in the current directory',
                  cmd: 'arli generate Blinker  ' },

                { desc: 'Populate initial Arlifile with the libs provided',
                  cmd: 'arli generate Weather --libs \'Adafruit Unified Sensor,Adafruit GFX Library,Time\' ' },
              ],

              parser: ->(command_name) {
                        make_parser(command_name) do |parser|
                          parser.banner = usage_line 'generate' + ' project-name '.magenta
                          parser.option_generate
                          parser.option_help(command_name: command_name)
                        end
                      }
            ),

            bundle: Hashie::Mash.new(
              sentence: 'Installs all libraries specified in Arlifile',
              description: %[This command reads #{'Arlifile'.bold.green} (from the current folder, by default),
                              and then it installs all dependent libraries specified there, checking if
                              each already exists, and if not — downloading them, and installing them into
                              your Arduino Library folder. Both the folder with the Arlifile, as well as the
                              destination library path folder can be changed with the command line flags.
                          ],
              example: [
                { desc: 'Install all libs defined in Arlifile:',
                  cmd: 'arli bundle ' },

                { desc: 'Custom Arlifile location, and destination path:',
                  cmd: 'arli bundle -a ./src -l ./libraries' }
              ],

              parser: ->(command_name) {
                        make_parser(command_name) do |parser|
                          parser.banner = usage_line 'bundle'
                          parser.option_bundle
                          parser.option_help(command_name: command_name)
                        end
                      }
            ),

            install: Hashie::Mash.new(
              sentence: 'Installs a single library either by searching, or url or local ZIP',
              description: %[This command installs a single library into your library path
                                 (which can be set with #{'--lib-path'.blue} flag).
                                 Arli interprets the third argument to #{'arli install'.bold.blue}
                                 as either an exact library name, or a remote URL
                                 (either ZIP or Git Repo). You can use #{'search'.bold.green} command
                                 to first find the right library name, and then pass it to the install command.
                             ],
              examples: [
                { desc: 'Install the latest version of this library locally',
                  cmd: 'arli install "Adafruit GFX Library" -l ./libraries' },

                { desc: 'Install the library from a Github URL',
                  cmd: 'arli install https://github.com/jfturcot/SimpleTimer' }
              ],

              parser: ->(command_name) {
                        make_parser(command_name) do |parser|
                          parser.banner = usage_line 'install' + ' [ "Exact Library Name" | url ] '.magenta
                          parser.option_install
                          parser.option_help(command_name: command_name)
                        end
                      }
            ),
          }
        end

        def aliases
          {
            s: :search,
            ser: :search,
            i: :install,
            ins: :install,
            g: :generate,
            gen: :generate,
            b: :bundle,
            bun: :bundle
          }
        end

        def command_aliases(cmd)
          aliases.keys.select { |k| aliases[k] == cmd }
        end

        def commands
          command_parsers.keys
        end

        def valid_command?(command)
          commands.include?(command) || aliases[command]
        end

        def command_from_arg(arg)
          if commands.include?(arg)
            arg
          elsif aliases[arg]
            aliases[arg]
          end
        end

        def command_parser(cmd)
          cmd_hash = command_parsers[cmd] || command_parsers[aliases[cmd]]
          cmd_hash ? cmd_hash[:parser].call(cmd) : nil
        end

        def global_usage(command)
          'Usage:'.magenta.bold +
            "\n    " + arli_command + ' options '.yellow +
            "\n    " + arli_command + ' ' + ((command || 'command')).cyan.bold + ' [ options ] '.yellow + "\n"
        end

        def arli_command
          @arli_command ||= Arli::Configuration::ARLI_COMMAND.blue.bold
        end

        def command_usage(command)
          'Usage:'.magenta.bold +
            "\n    " + arli_command + ' ' + command.bold.cyan + ' [options]'.yellow + "\n\n" +
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
