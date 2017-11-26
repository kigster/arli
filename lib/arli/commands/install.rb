require 'json'
require 'arli'
require 'net/http'
require_relative 'base'
require_relative '../actions/installer'

module Arli
  module Commands
    class Install < Base

      attr_accessor :arlifile

      def initialize(*args)
        super(*args)
      end

      def setup
        self.arlifile = Arli::ArliFile.new(config: config)
      end

      def params
        arlifile.file
      end

      def run
        arlifile.each_dependency do |lib|
          Arli::Actions::Installer.new(lib, self).install
        end
      end
    end
  end
end
