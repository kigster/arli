# frozen_string_literal: true

require 'arli'
require 'yaml'
require 'forwardable'
require 'arduino/library'
require 'hashie/mash'

require_relative 'formats'

module Arli
  module Lock
    class File
      attr_accessor :lock_file_path,
                    :config,
                    :formatter,
                    :file,
                    :format,
                    :arlifile

      def initialize(config: Arli.config, arlifile: nil)
        self.config         = config
        self.arlifile       = arlifile
        self.format         = config.arlifile&.lock_format
        self.formatter      = set_formatter(format)
        self.lock_file_path = "#{config.arlifile&.path}/#{config.arlifile&.name}.#{formatter.extension}"
        self.file           = ::File.open(lock_file_path, 'w')
      end

      def lock(*libraries)
        append(formatter.header)
        libraries.each do |lib|
          append(formatter.format(lib))
        end
        append(formatter.footer)
      ensure
        close
      end

      def lock!(*args)
        lock(*args)
      end

      def close
        file.close
      rescue StandardError
        nil
      end

      def append(line = nil)
        return unless line

        line.end_with?("\n") ? file.print(line) : file.puts(line)
      end

      private

      def set_formatter(format)
        klass = format.to_s.capitalize.to_sym
        klazz = ::Arli::Lock::Formats.const_get(klass)
        klazz.new(self)
      rescue NameError
        raise Arli::Errors::ArliError,
              "invalid format #{format}, Arli::Lock::Formats::#{klass} does not exist"
      end
    end
  end
end
