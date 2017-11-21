require 'json'
require 'fileutils'
require 'open3'
require 'arli'
require 'arli/version'
require 'arli/errors'

module Arli
  module Commands
    class Base
      attr_accessor :lib_path,
                    :arlifile,
                    :abort_if_exists,
                    :create_backup,
                    :command,
                    :debug,
                    :trace

      def initialize(options)
        self.lib_path        = options[:lib_home]
        self.abort_if_exists = options[:abort_if_exists]
        self.create_backup   = options[:create_backup]
        self.debug           = options[:debug]
        self.trace           = options[:trace]

        self.command = self.class.name.gsub(/.*::/, '').downcase.to_sym
        setup
      end

      def name
        self.class.name.gsub(/.*::/, '').downcase
      end

      def setup
        FileUtils.mkdir_p(lib_path)
      end

      def error(msg, exception = nil)
        printf 'Runtime Error: '.red + "\n#{msg}\n" if msg
        if exception
          puts
          printf 'Exception: '.red + "\n#{exception.inspect.red}\n\n"
        end
        puts
      end

      def info(msg, header = nil)
        printf('%-20s', header.blue) if header
        printf((header ? ' : ' : '') + msg + "\n") if msg
      end

    end
  end
end
