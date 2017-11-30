require 'json'
require 'fileutils'
require 'open3'
require 'arli'
require 'arli/commands/base'
require 'arli/errors'
require 'arduino/library'

module Arli
  module Commands
    class Search < Base
      require 'arduino/library/include'

      attr_accessor :search_string,
                    :search_opts,
                    :results,
                    :limit,
                    :database

      def initialize(*args)
        super(*args)
      end

      def process_search
        puts runtime.argv.inspect.bold.red
        puts Arli.config.search.to_hash

        search             = runtime.argv.first

        self.search_string = if search =~ /:/
                               search
                             elsif search
                               "#{config.search.default_field}: /#{search}/"
                             end

        self.limit = config.search.results.limit

        unless search_string
          raise Arli::Errors::InvalidSyntaxError,
                'Please provide search string after the "search" command'
        end

        begin
          self.search_opts = eval("{ #{search_string} }")
        rescue => e
          message = e.message
          if message =~ /undefined method.*Arduino::Library::Model/
            message = "Invalid attributed search. Possible values are:\n#{Arduino::Library::Types::LIBRARY_PROPERTIES.keys}"
          end
          raise Arli::Errors::InvalidSyntaxError, "Search string '#{search_string}' is invalid.\n" +
              message.red
        end

        unless search_opts.is_a?(::Hash) && search_opts.size > 0
          raise Arli::Errors::InvalidSyntaxError, "Search string '#{search_string}' did not eval to Hash.\n"
        end

        self.database = db_default

        search_opts.merge!(limit: limit) if limit && limit > 0
        search_opts.delete(:limit) if limit == 0
      end

      def run
        process_search
        self.results = search(database, **search_opts)
        results.sort.map do |lib|
          puts pretty_library(lib)
        end
        puts "\nTotal matches: #{results.size.to_s.bold.magenta}"
      rescue Exception => e
        error e
        puts e.backtrace.join("\n") if ENV['DEBUG']
      end

      def pretty_library(lib, **options)
        "#{lib.name.bold.blue} (#{lib.version.yellow}), by #{lib.author.magenta}"
      end

      def params
        search_opts
      end
    end
  end
end
