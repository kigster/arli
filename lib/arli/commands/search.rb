require 'json'
require 'fileutils'
require 'open3'
require 'arli'
require 'arli/commands/base'
require 'arli/errors'
require 'arduino/library'
require 'awesome_print'

module Arli
  module Commands
    class Search < Base
      require 'arduino/library/include'

      attr_accessor :search_string,
                    :search_opts,
                    :limit,
                    :database

      def initialize(*args)
        super(*args)
      end

      def setup
        search = runtime.argv.first
        self.search_string = if search =~ /:/
                               search
                             else
                               "name: /#{search}/"
                             end

        self.limit = config.search.results.limit

        raise Arli::Errors::InvalidSyntaxError,
              'Please provide search string after the "search" command' \
          unless search_string

        begin
          self.search_opts = eval("{ #{search_string} }")
        rescue => e
          raise Arli::Errors::InvalidSyntaxError, "Search string '#{search_string}' is invalid.\n" +
              e.message.red
        end

        unless search_opts.is_a?(::Hash) && search_opts.size > 0
          raise Arli::Errors::InvalidSyntaxError, "Search string '#{search_string}' did not eval to Hash.\n"
        end

        self.database = db_default
        search_opts.merge!(limit: limit) if limit && limit > 0
      end

      def run
        puts search(database, **search_opts).map { |l| "#{l.name} (#{l.version})" }.join("\n")
      rescue Exception => e
        error e
        puts e.backtrace.join("\n") if ENV['DEBUG']
      end

      def params
        search_opts
      end
    end
  end
end
