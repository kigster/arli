require 'arduino/library'
require 'arli/config'
require 'arli/version'

module Arli
  class CLI
    class Parser < OptionParser
      attr_accessor :output_lines, :command, :options, :arlifile

      def initialize(command = nil)
        super(nil, 22)
        self.output_lines        = ::Array.new
        self.command             = command
        self.options             = ::Hashie::Mash.new
        self.arlifile            = options[:arli_dir] ?
                                     options[:arli_dir] + '/' + Arli::Config::DEFAULT_FILENAME :
                                     Arli::Config::DEFAULT_FILENAME
        self.options[:arlifile] = arlifile
      end

      def sep(text = nil)
        separator text || ''
      end

      def option_dependency_file
        on('-p', '--arli-path PATH',
           'Folder where ' + 'Arlifile'.green + ' is located,',
           "Defaults to the current directory.\n\n") do |v|
          options[:arli_dir] = v
        end
      end

      def option_lib_home
        on('-l', '--libs PATH', 'Local folder where libraries are installed',
           "Defaults to #{default_library_path}\n\n") do |v|
          options[:lib_home] = v
        end
      end

      def option_search
        on('-d', '--database FILE/URL',
           'a JSON file name, or a URL that contains the index',
           'Defaults to the Arduino-maintained list') do |v|
          options[:database] = v
        end
        on('-m', '--max NUMBER',
           'if provided, limits the result set to this number',
           'Defaults to 100') do |v|
          options[:limit] = v.to_i if v
        end
      end

      def option_abort_if_exists
        on('-e', '--if-exists ACTION',
           'If a library folder already exists, by default',
           'it will be overwritten or updated if possible.',
           'Alternatively you can either ' + 'abort'.bold.blue + ' or ' + 'backup'.bold.blue
        ) do |v|
          if v =~ /abort/i
            options[:abort_if_exists] = true
          elsif v =~ /backup/
            options[:create_backup] = true
            elsif v =~ /replace/
          end
        end
        sep ' '
      end

      def option_help(commands: false, command_name: nil)
        on('-D', '--debug',
           'Print debugging info.') do |v|
          options[:debug] = true
        end
        on('-t', '--trace',
           'Print exception stack traces.') do |v|
          options[:trace] = v
        end
        on('-v', '--verbose',
           'Print more information.') do |v|
          options[:verbose] = true
        end
        on('-V', '--version',
           'Print current version and exit') do |v|
          output 'Version: ' + Arli::VERSION
          options[:help] = true
        end
        on('-h', '--help', 'prints this help') do
          output 'Description:' if command_name
          output ' ' * 4 + command_name[:description].green if command_name
          output ''
          output_help
          output_command_help if commands

          if command_name && command_name[:example]
            output 'Example:'
            output ' ' * 4 + command_name[:example]
          end

          options[:help] = true
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

        ::Arli::CLI.commands.each_pair do |command, config|
          subtext << %Q/#{sprintf('    %-12s', command.to_s).green} : #{sprintf('%s', config[:description]).yellow}\n/
        end
        subtext << <<-EOS
        
See #{COMMAND.blue + ' <command> '.green + '--help'.yellow} for more information on a specific command.

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

      def default_library_path
        ::Arli.config.library_path.gsub(%r(#{ENV['HOME']}), '~').blue
      end
    end
  end
end
