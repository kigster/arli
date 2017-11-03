require 'json'
require 'fileutils'
require 'open3'
require 'arli'
require 'arli/commands/base'
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

      class InvalidOptionError < ArgumentError;
      end

      def initialize(options)
        super(options)
        self.search_string = options[:argv].first

        puts "using search string [#{search_string}]" if search_string && Arli.debug?
        self.limit = options[:limit] || 100

        raise InvalidOptionError, 'Please provide search string after the "search" command' \
          unless search_string

        begin
          self.search_opts = eval("{ #{search_string} }")
        rescue => e
          raise InvalidOptionError "Search string '#{search_string}' is invalid.\n" +
                                     e.message.red
        end

        unless search_opts.is_a?(::Hash) && search_opts.size > 0
          raise InvalidOptionError, "Search string '#{search_string}' did not eval to Hash.\n"
        end

        self.database = options[:database] ? db_from(option[:database]) : db_default

        search_opts.merge!(limit: limit) if limit && limit > 0
      end

      def run
        ap search(database, **search_opts).map(&:to_hash)
      rescue Exception => e
        error e
        puts e.backtrace.join("\n") if ENV['DEBUG']
      end
    end
  end
end
