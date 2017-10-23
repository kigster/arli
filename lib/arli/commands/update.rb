require 'json'
require 'fileutils'
require 'open3'
require 'arli'
require_relative 'base'

module Arli
  module Commands
    class Update < Base
      def initialize(options)
        super(options)
        self.arli_file = options[:arli_file] ? ArliFile.new(options[:arli_file]) : ArliFile.new
      end

      def run
        all_dependencies(command, 'name')
      end

      def update_dependency(name)
        cmd = "cd #{name} && git pull --rebase 2>&1"
        yield(cmd) if block_given?
        cmd
      end
    end
  end
end
