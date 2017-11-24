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

      attr_accessor :lib_path,
                    :arlifile,
                    :abort_if_exists,
                    :create_backup,
                    :command,
                    :debug,
                    :trace

      def initialize(options)
        self.lib_path        = options[:lib_home]
        self.abort_if_exists = options[:abort_if_exists]
        self.create_backup   = options[:create_backup]
        self.debug           = options[:debug]
        self.trace           = options[:trace]

        self.command = self.class.name.gsub(/.*::/, '').downcase.to_sym
        setup
      end

      def name
        self.class.name.gsub(/.*::/, '').downcase
      end

      def setup
        FileUtils.mkdir_p(lib_path)
      end

    end
  end
end
