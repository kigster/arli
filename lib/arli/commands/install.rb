require 'json'
require 'fileutils'
require 'open3'
require 'arli'
require 'arli/commands/base'

module Arli
  module Commands
    class Install < Base

      def run
        install_dependencies
      end

      private

      def setup
        FileUtils.mkdir_p(lib_path)
        yield self if block_given?
        self
      end
    end
  end
end
