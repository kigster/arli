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
        arli_file.each_dependency do |lib|
          execute(
            command_for_dependency(::Arduino::Library::Resolver.resolve(lib))
          )
        end
      end

      def command_for_dependency(lib)
        "cd #{lib.name} && git pull --rebase 2>&1"
      end
    end
  end
end
