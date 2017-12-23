require 'json'
require 'fileutils'
require 'open3'
require 'arli'
require 'arli/commands/base'
require 'arli/errors'
require 'arli/library/multi_version'
require 'arduino/library'


module Arli
  module Commands
    class Search < Base

      require 'arduino/library/include'

      attr_accessor :search_string,
                    :search_opts,
                    :search_method,
                    :results,
                    :limit,
                    :database,
                    :format,
                    :unique_libraries

      def initialize(*args)
        super(*args)
        self.format = config.search.results.output_format
        valid_methods = Arli::Library::MultiVersion.format_methods
        raise Arli::Errors::InvalidSearchSyntaxError,
              "invalid format #{format}" unless valid_methods.include?(format)
      end

      def run
        self.search_opts      = process_search_options!
        self.results          = search(database, **search_opts).sort
        self.unique_libraries = Set.new

        results.map { |lib| add_lib_or_version(lib) }

        unique_libraries.each do |multi_version|
          puts multi_version.send("to_s_#{format}".to_sym)
        end
        print_total_with_help
      rescue Exception => e
        error e
        puts e.backtrace.join("\n") if ENV['DEBUG']
      end

      def add_lib_or_version(lib)
        a_version = Arli::Library::MultiVersion.new(lib)
        if unique_libraries.include?(a_version)
          unique_libraries.find { |l| l.name == a_version.name }&.add_version(library: lib)
        else
          unique_libraries << a_version
        end
      end

      def process_search_options!
        self.search_string = extract_search_argument!
        raise_error_unless_search_string!

        self.limit  = config.search.results.limit
        search_opts = {}
        begin
          params_code = "{ #{search_string} }"
          puts "Evaluating: [#{params_code.blue}]\nSearch Method: [#{search_method.to_s.green}]" if config.trace
          search_opts = eval(params_code)

        rescue => e
          handle_and_raise_error(e)
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
          self.search_method = :ruby
          search
        elsif search.start_with?('/')
          self.search_method = :regex_name_and_url
          # exact match
          "#{config.search.default_field}: #{search}, archiveFileName: #{search}"
        elsif search.start_with?('=')
          self.search_method = :equals
          # exact match
          "#{config.search.default_field}: '#{search[1..-1]}'"
        elsif search
          self.search_method = :regex
          "#{config.search.default_field}: /#{search.downcase}/i"
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
        puts "———————————————————————"
        puts "  Total Versions : #{results.size.to_s.bold.magenta}\n"
        puts "Unique Libraries : #{unique_libraries.size.to_s.bold.magenta}\n"
        puts "———————————————————————"
        if results.size == Arli::Configuration::DEFAULT_RESULTS_LIMIT
          puts "Hint: use #{'-m 5'.bold.green} to limit the result set."
        end
      end

      def params
        search_opts
      end
    end
  end
end
