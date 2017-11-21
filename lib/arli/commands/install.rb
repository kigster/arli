require 'json'
require 'arli'
require 'net/http'
require_relative 'base'
require_relative '../installers/zip_file'

module Arli
  module Commands
    class Install < Base

      def initialize(options)
        super(options)
        self.arlifile = Arli::ArliFile.new(lib_path:      lib_path,
                                           arlifile_path: options[:arli_dir])
      end

      def run
        arlifile.each_dependency do |lib|
          Arli::Installer.new(lib: lib, command: self).install
        end
      end

    end
  end
end
