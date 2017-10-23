require 'arduino/library'
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
           "Default filename is #{DEFAULT_ARLI_FILE.bold.magenta})\n\n") do |v|
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
        on('-s', '--search TERMS', 'ruby-style hash arguments to search for',
           %Q(eg: -s "name: 'AudioZero', version: /^1.0/")) do |v|
          options[:search] = v
        end
        on('-d', '--database SOURCE',
           'a JSON file name, or a URL that contains the index',
           'By default, the Arduino-maintained list is searched') do |v|
          options[:database] = v
        end
        on('-m', '--max LIMIT',
           'if provided, limits the result set to this number',
           'Default value is 100') do |v|
             options[:limit] = v.to_i 
        end
      end

      def option_abort_if_exists
        on('-e', '--abort-on-exiting',
           'Abort if a library folder already exists',
           'instead of updating it.') do |v|
          options[:abort_if_exists] = true
        end
      end

      def option_help(commands: false, command: nil)
        on('-h', '--help', 'prints this help') do
          puts 'Description:'.bold if command
          output ' ' * 4 + command[:description].bold.green if command
          output ''
          output_help
          output_command_help if commands
          options[:help] = true
        end
      end

      def option_library
        on('-n', '--lib-name LIBRARY', 'Library Name') { |v| options[:library_name] = v }
        on('-f', '--from FROM', 'A git or https URL') { |v| options[:library_from] = v }
        on('-v', '--version VERSION', 'Library Version, i.e. git tag') { |v| options[:library_version] = v }
        on('-i', '--install', 'Install a library') { |v| options[:library_action] = :install }
        on('-r', '--remove', 'Remove a library') { |v| options[:library_action] = :remove }
        on('-u', '--update', 'Update a local library') { |v| options[:library_action] = :update }
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
        Arduino::Library::DEFAULT_ARDUINO_LIBRARY_PATH.gsub(%r(#{ENV['HOME']}), '~').blue
      end

    end
  end
end
