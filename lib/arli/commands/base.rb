require 'json'
require 'fileutils'
require 'open3'
require 'arli'
require 'arli/version'
require 'arli/errors'
require 'arli/output'

module Arli
  module Commands
    class Base
      include Arli::Output

      attr_accessor :config, :name

      def initialize(config: Arli.config)
        self.config = config
        FileUtils.mkdir_p(library_path) unless Dir.exist?(library_path)
        setup
      end

      def run(*args)
        raise ArgumentError, 'This method must be implemented in subclasses'
      end

      def runtime
        config.runtime
      end

      def name
        @name ||= self.class.name.gsub(/.*::/, '').downcase.to_sym
      end

      def library_path
        config.libraries.path
      end

      def setup

      end

      def params

      end
    end
  end
end
