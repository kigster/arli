require 'json'
require 'arli'
require 'net/http'
require_relative 'base'

module Arli
  module Commands
    class Bundle < Base

      attr_accessor :arlifile

      def initialize(*args)
        super(*args)
      end

      def setup
        self.arlifile = Arli::ArliFile.new(
            config:    config,
            libraries: Arli.config.bundle.library_names)
      end

      def params
        "libraries: \n • " + arlifile.dependencies.map(&:name).join("\n • ")
      end

      def run
        arlifile.each_dependency { |lib| lib.install }
      end
    end
  end
end
