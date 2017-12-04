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
                    :database,
                    :format

      def initialize(*args)
        super(*args)
        self.format = :short
      end


      def run
        self.search_opts = process_search_options!
        self.results     = search(database, **search_opts).sort

        results.map do |lib|
          method = "to_s_#{format}".to_sym
          lib.send(method) if lib.respond_to?(method)
        end
        print_total_with_help
      rescue Exception => e
        error e
        puts e.backtrace.join("\n") if ENV['DEBUG']
      end

      private

        def process_search_options!
          self.search_string = extract_search_argument!
          raise_error_unless_search_string!

          self.limit = config.search.results.limit

          search_opts = {}
          begin
            search_opts = eval("{ #{search_string} }")
          rescue => e
            handle_error(e)
          end

          unless search_opts.is_a?(::Hash) && search_opts.size > 0
            raise Arli::Errors::InvalidSearchSyntaxError,
                  "Search string '#{search_string}' did not eval to Hash.\n"
          end

          self.database = db_default

          search_opts.merge!(limit: limit) if limit && limit > 0
          search_opts.delete(:limit) if limit == 0
          search_opts
        end

        def extract_search_argument!
          search = runtime.argv.first
          if search =~ /:/
            search
          elsif search
            "#{config.search.default_field}: /#{search}/"
          end
        end

        def raise_error_unless_search_string!
          unless search_string
            raise Arli::Errors::InvalidSyntaxError,
                  'Expected an argument or a flag to follow the command ' + 'search'.bold.green
          end
        end

        def handle_and_raise_error(e)
          message = e.message
          if message =~ /undefined method.*Arduino::Library::Model/
            message = "Invalid attributed search. Possible values are:" +
                "\n#{Arduino::Library::Types::LIBRARY_PROPERTIES.keys}"
          end
          raise Arli::Errors::InvalidSearchSyntaxError,
                "Search string '#{search_string}' is invalid.\n" +
                    message.red
        end

        def print_total_with_help
          puts "\nTotal matches: #{results.size.to_s.bold.magenta}"
          if results.size == Arli::Configuration::DEFAULT_RESULTS_LIMIT
            puts "Hint: use #{'-m 0'.bold.green} to disable the limit, or set it to another value."
          end
        end

        def params
          search_opts
        end
    end
  end
end
