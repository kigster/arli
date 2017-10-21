require 'json'
require 'fileutils'
require 'open3'
require 'arli'
require_relative 'base'

module Arli
  module Commands
    class Update < Base

      def run
        header
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
