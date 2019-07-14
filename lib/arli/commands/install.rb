# frozen_string_literal: true

require 'hashie/mash'
require 'net/http'
require 'json'
require 'arli'

require 'arduino/library'
require_relative 'base'
require_relative 'bundle'
require 'arli/library'

module Arli
  module Commands
    class Install < Base
      require 'arduino/library/include'
      include Arduino::Library::InstanceMethods

      attr_accessor :library,
                    :arlifile,
                    :install_argument,
                    :install_method

      include ::Arli::Library

      def setup
        self.install_argument = runtime.argv.first
        unless install_argument
          raise InvalidInstallSyntaxError,
                'Missing installation argument: a name, a file or a URL.'
        end

        self.library = identify_library(install_argument)
        unless library
          raise Arli::Errors::LibraryNotFound,
                "Library #{cfg.to_hash} was not found"
        end

        self.arlifile = Arli::ArliFile.new(config: config, libraries: [library])
        if config.trace
          info("found library using #{install_method}:\n#{library.inspect}")
        end
      end

      def additional_info
        "\nInstalling: #{runtime.argv.join(' ').bold.green}\n"
      end

      def run
        arlifile.install
      end

      # arg can be 'Adafruit GFX Library'
      def identify_library(arg)
        results = if arg =~ %r[https?://]i
                    self.install_method = :url
                    result = search url: /^#{arg}$/i

                    if result.empty?
                      self.install_method = :website
                      result = search(website: /^#{arg}$/i)
                    end

                    if result.empty?
                      self.install_method = :custom
                      result = [Arduino::Library::Model.from_hash(url: arg, name: File.basename(arg))]
                    end
                    result
                  elsif File.exist?(arg) || arg =~ /\.zip$/
                    self.install_method = :archiveFileName
                    search archiveFileName: File.basename(arg).to_s
                  else
                    self.install_method = :name
                    search name: /^#{arg}$/
                  end

        validate_search(arg, results)
        results.max if results && !results.empty?
      end

      def params
        nil
      end

      def post_install; end

      def search(**opts)
        # noinspection RubyArgCount
        super(opts)
      end

      private

      def validate_search(arg, results)
        if results.nil? || results.empty?
          raise Arli::Errors::LibraryNotFound,
                "Can't find library by argument #{arg.bold.yellow}, searching by #{install_method}"
        end
        dupes = results.map(&:name).uniq.size
        if dupes > 1
          raise Arli::Errors::TooManyMatchesError,
                "More than one match found for #{arg.bold.yellow} — #{dupes} libraries matched"
        end
      end

      def cfg
        config.install
      end
    end
  end
end
