require 'json'
require 'fileutils'
require 'open3'
require 'arli'
require 'arli/version'
require 'arli/errors'

require_relative 'helpers'

module Arli
  module Commands
    class Base
      attr_accessor :lib_path, :arlifile, :abort_if_exists, :command

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
