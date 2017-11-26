require 'arli/configuration'

module Arli
  module CLI
    class Parser < OptionParser

      attr_accessor :output_lines,
                    :command,
                    :config

      def initialize(config: Arli.config, command: nil)
        super(nil, 22)

        self.config       = config
        self.command      = command
        self.output_lines = ::Array.new
      end

      def sep(text = nil)
        separator text || ''
      end

      def option_dependency_file
        on('-a', '--arli-path PATH',
           'Folder where ' + 'Arlifile'.green + ' is located,',
           "Defaults to the current directory.\n\n") do |v|
          config.arlifile.path = v
        end
      end

      def option_lib_home
        on('-l', '--libraries PATH',
           'Local folder where libraries are installed',
           "Defaults to #{Arli.default_library_path}\n\n") do |v|
          config.libraries.path = v
        end
      end

      def option_search
        on('-d', '--database FILE/URL',
           'a JSON file name, or a URL that contains the index',
           'Defaults to the Arduino-maintained list') do |v|
          config.database.path = v
        end

        on('-m', '--max NUMBER',
           'if provided, limits the result set to this number',
           'Defaults to 100') do |v|
          config.search.results.limit = v.to_i if v
        end
      end

      def option_abort_if_exists
        on('-e', '--if-exists ACTION',
           'If a library folder already exists, by default',
           'it will be overwritten or updated if possible.',
           'Alternatively you can either ' + 'abort'.bold.blue + ' or ' + 'backup'.bold.blue
        ) do |v|
          if v == 'abort'
            config.install.if_exists.abort     = true
            config.install.if_exists.overwrite = false
          elsif v == 'backup'
            config.install.if_exists.backup = true
          end
        end
        sep ' '
      end

      def option_help(commands: false, command_name: nil)
        common_help_options

        on('-h', '--help', 'prints this help') do
          ::Arli.config.help = true

          is_command = command_name && command_name.is_a?(Hash)

          if is_command
            output 'Description:'
            output '    ' + command_name
            output ''
          end

          output_help
          output_command_help if commands

          if is_command && command_name[:example]
            output 'Example:'
            output '     ' + command_name[:example]
          end
        end
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

        subtext = "Available Commands:\n"
        factory.command_parsers.each_pair do |command, config|
          subtext << %Q/#{sprintf('    %-12s', command.to_s).green} — #{sprintf('%s', config[:description]).blue}\n/
        end
        subtext << <<-EOS

See #{Arli::Configuration::ARLI_COMMAND.blue + ' command '.green + '--help'.yellow} for more information on a specific command.

        EOS
        subtext
      end

      def output(value = nil)
        self.output_lines << value if value
        self.output_lines
      end

      def print
        puts output.join("\n") unless output.empty?
      end

      def factory
        Arli::CLI::ParserFactory
      end

      def common_help_options
        on('-D', '--debug',
           'Print debugging info.') do |v|
          config.debug = true
        end
        on('-t', '--trace',
           'Print exception stack traces.') do |v|
          config.trace = v
        end
        on('-v', '--verbose',
           'Print more information.') do |v|
          config.verbose = true
        end
        on('-V', '--version',
           'Print current version and exit') do |v|
          puts 'Version: ' + Arli::VERSION
          exit
        end
      end
    end
  end
end
