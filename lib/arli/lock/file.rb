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
                    :format

      def initialize(config: Arli.config)
        self.config         = config
        self.lock_file_path = "#{config.arlifile.path}/#{config.arlifile.lock_name}"
        self.format         = config.arlifile.lock_format
        self.formatter      = set_formatter(format)
        self.file           = ::File.open(lock_file_path, 'w')

        append(formatter.header)
      end

      def lock(*libraries)
        libraries.each do |lib|
          append(formatter.format(lib))
        end
      end

      def lock!(*args)
        lock(*args)
      ensure
        close
      end

      def close
        append(formatter.footer)
      ensure
        file.close
        FileUtils.cp(lock_file_path, "#{lock_file_path}.#{format}")
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

