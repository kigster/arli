require 'json'
require 'arli'
require 'net/http'
require_relative 'base'

module Arli
  module Commands
    class Install < Base

      attr_accessor :arlifile

      def initialize(*args)
        super(*args)
      end

      def cfg
        config.install
      end

      def setup
        self.arlifile = Arli::ArliFile.new(
            config:    config,
            libraries: [library_argument])
      end

      def params
        "library: #{library_argument}"
      end

      def run
        arlifile.each_dependency { |lib| lib.install }
      end

      private

      def library_argument
        lib        = Hash.new
        lib['name'] = cfg.name if cfg.name

        if cfg.url
          lib['url']  = cfg.url
          lib['name'] ||= File.basename(cfg.url)
        end

        require 'pp'
        pp lib
        lib
      end
    end
  end
end
