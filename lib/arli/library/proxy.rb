require_relative 'installer'
require 'arli/errors'

module Arli
  module Library
    # Represents a wrapper around Arduino::Library::Model instance
    # and decorates with a few additional helpers.
    class Proxy
      attr_accessor :lib,
                    :lib_dir,
                    :canonical_dir,
                    :config

      def initialize(lib, config: Arli.config)
        self.lib     = lib
        self.config  = config
        self.lib_dir = lib.name.gsub(/ /, '_')
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

      # Formats
      def to_s_short
        "#{lib.name.bold.blue} (#{lib.version.yellow}), by #{lib.author.magenta}"
      end

      def to_s_json
        puts lib.to_json
      end

      def to_s_long
        "#{lib.name.bold.blue} (#{lib.version.yellow}), by #{lib.author.magenta}}\n\t#{lib.description}"
      end

      def to_s_pretty(lib, **options)
        "#{lib.name.bold.blue} (#{lib.version.yellow}), by #{lib.author.magenta}"
      end

      def method_missing(method, *args, &block)
        if lib && lib.respond_to?(method)
          lib.send(method, *args, &block)
        else
          super(method, *args, &block)
        end
      end

    end
  end
end
