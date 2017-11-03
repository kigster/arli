require 'json'
require 'fileutils'
require 'open3'
require 'arli'
require 'arli/version'

require_relative 'helpers'

module Arli
  module Commands
    class Base
      attr_accessor :lib_path, :arli_file, :abort_if_exists, :command

      include Helpers

      def initialize(options)
        self.lib_path        = options[:lib_home]
        self.abort_if_exists = options[:abort_if_exists]
        self.command         = self.class.name.gsub(/.*::/, '').downcase.to_sym
        setup
      end

      # Commands implement #run method that uses helpers below:
      protected

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
