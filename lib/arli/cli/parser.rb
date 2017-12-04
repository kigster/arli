require 'arli/configuration'
require 'colored2'
require 'optionparser'

module Arli
  module CLI
    class Parser < ::OptionParser

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
        option_if_exists
      end

      def option_bundle
        option_lib_home
        option_arlifile_path
        option_arlifile_lock_format
        option_if_exists
      end

      def option_arlifile_path
        on('-a', '--arli-path PATH',
           'An alternate folder with the ' + 'Arlifile'.green + ' file.',
           "Defaults to the current directory.\n\n") do |v|
          config.arlifile.path = v
        end
      end

      SUPPORTED_FORMATS = %w[cmake text json yaml]

      def option_arlifile_lock_format
        on('-f', '--format FMT',
           "Arli writes an #{'Arlifile.lock'.green} with resolved info.",
           "The default format is #{'text'.bold.yellow}. Use -f to set it",
           "to one of: #{SUPPORTED_FORMATS.join(', ').bold.yellow}\n\n") do |v|
          if SUPPORTED_FORMATS.include?(v.downcase)
            config.arlifile.lock_format = v.downcase.to_sym
          else
            raise ::OptionParser::InvalidOption,
                  "#{v.yellow} is not a supported lock file format"
          end
        end
      end

      def option_lib_home
        on('-l', '--lib-path PATH',
           'Destination: typically your Arduino libraries folder',
           "Defaults to #{'~/Documents/Arduino/Libraries'.green}\n\n") do |v|
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

          command_hash = output_command_description(command_name)

          output_help
          output_command_help if commands

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
        indent = '    '
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
          subtext << %Q/#{sprintf('    %-12s', command.to_s).green} — #{sprintf('%s', config[:sentence]).blue}\n/
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
          Colored2.disable! # if $stdout.tty?
        end
        on('-D', '--debug',
           'Print debugging info.') do |v|
          config.debug = true
        end
        on('-t', '--trace',
           'Print exception stack traces.') do |v|
          config.trace = v
        end
        on('-n', '--dry-run',
           'Only print actions, but do not do them.') do |v|
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

      def output_command_description(command_name)
        command_hash = factory.command_parsers[command_name]
        indent = '    '

        if command_hash
          if command_hash.description
            header 'Description'
            if command_hash.sentence
              output indent + command_hash.sentence.bold
              output ''
            end
            output indent + Array(command_hash[:description]).map(&:dark).join('').gsub(/\n/, "\n#{indent}")
          end
        end

        command_hash
      end
    end
  end
end
