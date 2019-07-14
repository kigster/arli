# frozen_string_literal: true

require 'awesome_print'
require 'arli/errors'

require_relative 'installer'
require_relative 'multi_version'

module Arli
  module Library
    # Represents a wrapper around Arduino::Library::Model instance
    # and decorates with a few additional helpers.
    class SingleVersion
      attr_accessor :lib,
                    :lib_dir,
                    :canonical_dir,
                    :config

      # Additional attributes that can be set via Arlifile
      attr_accessor :headers_only,
                    :depends,
                    :folder # indicates a sub-folder of the library

      def initialize(lib, config: Arli.config)
        self.lib          = lib
        self.config       = config
        self.lib_dir      = lib.name.gsub(/ /, '_')
        self.headers_only = false
        self.depends      = nil
        self.folder       = nil
      end

      def install
        installer.install
      end

      def installer
        @installer ||= Installer.new(self)
      end

      def libraries_home
        config.libraries.path
      end

      def temp_dir
        config.libraries.temp_dir
      end

      def dir
        canonical_dir || lib_dir
      end

      def path
        libraries_home + '/' + dir
      end

      def temp_path
        temp_dir + '/' + dir
      end

      def exists?
        Dir.exist?(path)
      end

      def inspect
        <<~EOF
          Library: #{lib.name} (#{lib.url}), only headers? #{headers_only ? 'YES' : 'NO'}
        EOF
      end

      def method_missing(method, *args, &block)
        if lib&.respond_to?(method)
          lib.send(method, *args, &block)
        else
          super(method, *args, &block)
        end
      end
    end
  end
end
