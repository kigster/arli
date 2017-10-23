require 'json'
require 'fileutils'
require 'open3'
require 'arli'
require 'arli/version'

module Arli
  module Commands
    class Base
      attr_accessor :lib_path, :arli_file, :abort_if_exists, :command

      def initialize(options)
        self.lib_path        = options[:lib_home]
        self.abort_if_exists = options[:abort_if_exists]
        self.command         = self.class.name.gsub(/.*::/, '').downcase.to_sym
        setup
      end

      def header
        out  = "——————————————————————————————————————————————————————————\n"
        out  <<  "Arli           : Version #{::Arli::VERSION.bold.yellow}\n"
        out  << "Command        : #{command.to_s.bold.blue}\n" if command
        out  << "Library Path   : #{lib_path.bold.green}\n" if lib_path
        out  << "ArliFile       : #{arli_file.file.bold.magenta}\n" if
          arli_file && arli_file.file
        out << '——————————————————————————————————————————————————————————'

        info out

        self
      end

      # Commands implement #run method that uses helpers below:
      protected

      def all_dependencies(cmd, *args)
        for_each_dependency do |dep|
          begin
            method_name = "#{cmd}_dependency".to_sym
            argv        = args.map { |key| dep[key] }
            if self.respond_to?(method_name)
              info("dependency #{dep.inspect}: calling #{method_name} with args #{argv.inspect}") if Arli::DEBUG
              self.send(method_name, *argv) do |system_command|
                execute(system_command)
              end
            else
              raise ArgumentError,
                    "Method #{method_name.to_s.bold.blue} is not implemented on #{self.class.name.bold.red}"
            end
          end
        end
      rescue Exception => e
        error "Error while running command #{cmd}:\n\n#{e.message.bold.red}"
        if Arli::DEBUG
          error e.backtrace.join("\n")
        end
      end

      def setup
        FileUtils.mkdir_p(lib_path)
      end

      # @param <String> *args — list of arguments or a single string
      def execute(*args)
        cmd = args.join(' ')
        info cmd.bold.green
        o, e, s = Open3.capture3(cmd)
        puts o if o
        puts e.red if e
        s
      rescue Exception => e
        error "Error running [#{cmd.bold.yellow}]\n" +
                "Current folder is [#{Dir.pwd.bold.yellow}]", e
        raise e
      end

      def for_each_dependency(&_block)
        raise 'Library Path is nil!' unless lib_path
        FileUtils.mkpath(lib_path) unless Dir.exist?(lib_path)
        arli_file.each do |dependency|
          Dir.chdir(lib_path) do
            yield(dependency)
          end
        end
      end

      def error(msg, exception = nil)
        printf 'Runtime Error: '.bold.red + "\n#{msg}\n" if msg
        if exception
          puts
          printf 'Exception: '.red + "\n#{exception.inspect.red}\n\n"
        end
        puts
      end

      def info(msg, header = nil)
        printf('%-20s', header.bold.blue) if header
        printf((header ? ' : ' : '') + msg + "\n") if msg
      end

    end
  end
end
