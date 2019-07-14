# frozen_string_literal: true

require 'json'
require 'fileutils'
require 'open3'
require 'arli'
require 'arli/version'
require 'arli/errors'
require 'arli/helpers/output'

module Arli
  module Commands
    class Base
      include Arli::Helpers::Output

      attr_accessor :config, :name

      def initialize(config: Arli.config)
        self.config = config
        setup
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

      def temp_path
        config.libraries.temp_dir
      end

      def setup
        FileUtils.mkdir_p(library_path) unless Dir.exist?(library_path)
        FileUtils.mkdir_p(temp_path) unless Dir.exist?(temp_path)
      end

      def run(*_args)
        raise Arli::Errors::AbstractMethodCalled,
              'This method must be implemented in subclasses'
      end

      def params
        ''
      end
    end
  end
end
