require 'arduino/library'
require 'arli/config'

module Arli
  class CLI
    class Parser < OptionParser
      attr_accessor :output_lines, :command, :options

      def initialize(command = nil)
        super(nil, 22)
        self.output_lines = Array.new
        self.command      = command
        self.options      = Hashie::Mash.new
      end

      def sep(text = nil)
        separator text || ''
      end

      def option_dependency_file
        on('-a', '--arli-file FILE',
           'ArliFile.yml'.bold.green + ' is the file listing the dependencies',
           "Default filename is #{Arli.config.arlifile.name.bold.magenta})\n\n") do |v|
          options[:arli_file] = v
        end
      end

      def option_lib_home
        on('-l', '--lib-home HOME', 'Local folder where libraries are installed',
           "Default: #{default_library_path}\n\n") do |v|
          options[:lib_home] = v
        end
      end

      def option_search
        on('-d', '--database SOURCE',
           'a JSON file name, or a URL that contains the index',
           'By default, the Arduino-maintained list is searched') do |v|
          options[:database] = v
        end
        on('-m', '--max LIMIT',
           'if provided, limits the result set to this number',
           'Default value is 100') do |v|
             options[:limit] = v.to_i if v
        end
      end

      def option_abort_if_exists
        on('-e', '--abort-on-exiting',
           'Abort if a library folder already exists',
           'instead of updating it.') do |v|
          options[:abort_if_exists] = true
        end
      end

      def option_log
        on('-L', '--log LOG',
           'Write debugging info into the log file.') do |v|
          options[:logfile] = v
        end
      end

      def option_help(commands: false, command_name: nil)
        on('-h', '--help', 'prints this help') do
          output 'Description:'.bold if command_name
          output ' ' * 4 + command_name[:description].bold.green if command_name
          output ''
          output_help
          output_command_help if commands

          if command_name && command_name[:example]
            output 'Example:'.bold
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
        subtext = "Available Commands:\n".bold

        ::Arli::CLI.commands.each_pair do |command, config|
          subtext << %Q/#{sprintf('    %-12s', command.to_s).green} : #{sprintf('%s', config[:description]).yellow}\n/
        end
        subtext << <<-EOS
        
See #{COMMAND.bold.blue + ' <command> '.bold.green + '--help'.bold.yellow} for more information on a specific command.

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
        ::Arli.config.library.path.gsub(%r(#{ENV['HOME']}), '~').blue
      end
    end
  end
end
