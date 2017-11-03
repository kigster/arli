require 'json'
require 'arli'
require_relative 'base'
require 'arli/file/finder'

module Arli
  module Commands
    class Update < Base

      def initialize(options)
        super(options)
        self.arli_file = options[:arli_file] ?
                           Arli::ArliFile.new(Arli::File::Finder.verify_arli_file(options[:arli_file])) :
                           Arli::ArliFile.new(Arli::File::Finder.default_arli_file)
      end

      def run
        arli_file.each do |dependency|
          process_dependency(dependency)
        end
      end

      def process_dependency(lib)
        cmd = "cd #{lib.name} && git pull --rebase 2>&1"
        yield(cmd) if block_given?
        cmd
      end
    end
  end
end
