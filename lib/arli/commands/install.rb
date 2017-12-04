require 'hashie/mash'
require 'net/http'
require 'json'
require 'arli'

require 'arduino/library'
require_relative 'base'
require_relative 'bundle'

module Arli
  module Commands
    class Install < Bundle
      require 'arduino/library/include'

      attr_accessor :library

      def setup
        validate_argument

        self.library  = identify_library(runtime.argv.first)
        validate_library

        self.arlifile = Arli::ArliFile.new(config: config, libraries: [library]) if library
      end

      # arg can be 'Adafruit GFX Library'
      def identify_library(arg)
        if File.exist?(arg)
          begin
            Arduino::Library::Model.from(arg)
          rescue
            nil
          end
        elsif arg =~ %r[https?://]
          Arduino::Library::Model.from_hash(url: arg, name: File.basename(arg))
        else
          results = search(name: /^#{arg}$/i)
          validate_search(arg, results)
          results.sort.last if results && !results.empty?
        end
      end

      def params
        " • #{library.to_s}"
      end

      def post_install
        #
      end

      private

      def validate_search(arg, results)
        raise Arli::Errors::LibraryNotFound,
              "Can't find library by argument #{arg.bold.yellow}" if results.nil? || results.empty?
        raise Arli::Errors::TooManyMatchesError,
              "More than one match found for #{arg.bold.yellow}" if results.map(&:name).uniq.size > 1
      end

      def validate_library
        raise Arli::Errors::LibraryNotFound,
              "Library #{cfg.to_hash} was not found" unless library
      end

      def validate_argument
        raise InvalidInstallSyntaxError,
              "Missing installation argument: a name, a file or a URL." unless runtime.argv.first
      end

      def cfg
        config.install
      end
    end
  end
end
