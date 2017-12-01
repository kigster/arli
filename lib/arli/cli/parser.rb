require 'arli/configuration'
require 'colored2'
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

      def option_install
        option_lib_home
        option_install_library
        option_if_exists
      end

      def option_bundle
        option_lib_home
        option_arlifile_path
        option_if_exists
      end

      def option_arlifile_path
        on('-a', '--arli-path PATH',
           'Folder where ' + 'Arlifile'.green + ' is located,',
           "Defaults to the current directory.\n\n") do |v|
          config.bundle.arlifile.path = v
        end
      end

      def option_install_library
        on('-u', '--lib-url URL',
           'Attempts to install the library by its URL',
           'Github project URL or a downloadable Zip are supported.') do |v|
          config.install.url = v
        end
        on('-n', '--lib-name NAME',
           'Searches and installs library by its name,',
           'unless URL is also provided') do |v|
          config.install.name = v
        end
      end

      def option_lib_home
        on('-l', '--lib-path PATH',
           'Local folder where custom Arduino libraries are installed',
           "Defaults to #{Arli.default_library_path}\n\n") do |v|
          config.libraries.path = v
        end
      end

      def option_search
        on('-d', '--database URL',
           'a JSON(.gz) file path or a URL of the library database.',
           'Defaults to the Arduino-maintained database.') do |v|
          config.database.path = v
        end

        on('-m', '--max NUMBER',
           'if provided, limits the result set to this number',
           'Set to 0 to disable. Default is 100.') do |v|
          config.search.results.limit = v.to_i if v
        end

        # on('-f', '--format FORMAT',
        #    'Output format for search results, can be one of',
        #    'json, yaml, csv, props') do |v|
        #   raise ::OptionParser::InvalidOption, "Format #{v.yellow} is not supported"
        #   config.search.results.format = v
        # end
        #
        # on('-a', '--attrs a1,at2',
        #    'For YAML/JSON/Properties format, print only the ',
        #    'specified attributes, eg, "name,version"') do |v|
        #   config.search.results.attrs = v.split(',')
        # end

      end

      def option_if_exists
        on('-e', '--if-exists ACTION',
           'If a library folder already exists, by default',
           'it will be overwritten or updated if possible.',
           'Alternatively you can either ' + 'abort'.bold.blue + ' or ' + 'backup'.bold.blue
        ) do |v|
          if v == 'abort'
            config.if_exists.abort     = true
            config.if_exists.overwrite = false
          elsif v == 'backup'
            config.if_exists.backup = true
          end
        end
        sep ' '
      end

      def option_help(commands: false, command_name: nil)
        common_help_options

        on('-h', '--help', 'prints this help') do
          ::Arli.config.help = true

          output_help
          output_command_help if commands

          command_hash = factory.command_parsers[command_name]
          if command_hash && command_hash[:description]
            header 'Description'
            output '    ' + command_hash[:description]
            output ''
          end


          if command_hash && command_hash[:examples]
            output_examples(command_hash[:examples])
          else
            print_version_copyright
          end
        end
      end

      def header(string)
        output "#{string.bold.magenta}:"
        output
      end

      def output_examples(examples)
        header 'Examples'
        indent = '     '
        examples.each do |example|
          output
          output indent + '# ' + example[:desc]
          output indent + example[:cmd].green
          output ''
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

        header 'Available Commands'
        subtext = ''
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
        on('-C', '--no-color',
           'Disable any color output.') do |*|
          Colored2.disable!# if $stdout.tty?
        end
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
        on('-q', '--quiet',
           'Print less information.') do |v|
          config.quiet = true
        end
        on('-V', '--version',
           'Print current version and exit') do |v|
          print_version_copyright
          Arli.config.help = true
        end
      end

      def print_version_copyright
        output << Arli::Configuration::ARLI_COMMAND.bold.yellow + ' (' + Arli::VERSION.bold.green + ')' +
            ' © 2017 Konstantin Gredeskoul, MIT License.'.dark unless Arli.config.quiet
      end
    end
  end
end
