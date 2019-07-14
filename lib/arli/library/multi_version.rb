# frozen_string_literal: true

require 'forwardable'
require 'arli'
require 'arli/actions'
require_relative 'single_version'

module Arli
  module Library
    class MultiVersion
      class << self
        def format_methods
          new({}).methods.grep(/^to_s_/).map { |m| m.to_s.gsub(/^to_s_/, '') }.map(&:to_sym)
        end
      end

      attr_accessor :latest_version_library, :versions

      include ::Arli::Helpers::Output

      def ==(other)
        other.instance_of?(self.class) && name == other.name
      end

      alias eql? ==
      alias lib latest_version_library
      alias lib= latest_version_library=

      def initialize(a_lib = nil, versions = [])
        Colored2.disable! if Arli.config.no_color
        self.latest_version_library = a_lib if a_lib
        self.versions               = versions || []
        self.versions << a_lib.version if a_lib&.respond_to?(:version) && self.versions.empty?
      end

      def add_version(library: nil)
        if library
          if lib.nil? || library.version_to_i > lib.version_to_i
            self.latest_version_library = library
          end
          versions << library.version
        elsif version
          versions << library.version
        end
        normalize_version_array!
      end

      def name
        latest_version_library.name
      end

      def hash
        lib.name.hash
      end

      # Various print formats
      # --format <ARG> is inserted after "to_s_<format>"
      def to_s_with_versions(limit = 4)
        append do |out|
          out << library_name
          out << append_truncated_version_list(limit)
        end
      end

      def to_s_long
        lib_versions = versions.clone
        latest       = lib_versions.pop
        append do
          "\nName:        #{lib.name.bold.yellow}\n" \
            "Versions:    #{latest.bold.yellow}, #{lib_versions.reverse.join(', ').green}\n" +
            (lib.author ? "Author(s):   #{lib.author.red}\n" : '') +
            (lib.website ? "Website:     #{lib.website.cyan}\n" : '') +
            "Sentence:    #{lib.sentence.blue}\n" +
            (lib.paragraph && (lib.paragraph != lib.sentence) ?
                 "Description: #{reformat_wrapped(lib.paragraph).magenta}\n" : "\n")
        end
      end

      def to_s_short
        append do
          printf append_name[0..45]
          indent_cursor 48
          printf append_latest_version
          indent_cursor 60
          printf append_total_versions
        end
      end

      def to_s_json
        append do
          JSON.pretty_generate(lib.to_hash) + ','
        end
      end

      def to_s_yaml
        append do
          YAML.dump(lib.to_hash)
        end
      end

      private

      def stream
        @stream = StringIO.new
      end

      def append
        stream.tap do |out|
          out << yield if block_given?
        end.string
      end

      def append_architecture
        unless lib.architectures.empty? || lib.architectures.include?('*')
          append { "supports: #{lib.architectures.join(', ').bold.green}" }
        end
      end

      def append_name
        append { lib.name.magenta.to_s }
      end

      def append_author
        append { "by #{lib.author.blue}" }
      end

      def append_latest_version
        latest = versions.clone.pop
        append { " (#{latest.cyan})" }
      end

      def append_total_versions
        append { "(#{format('%2d', versions.size)} total versions )".green }
      end

      def append_truncated_version_list(limit)
        append { truncate_version_list(limit) }
      end

      def normalize_version_array!
        self.versions = versions.flatten.compact.uniq.sort
      end

      def reformat_wrapped(s, width = 70)
        s.gsub(/\s+/, ' ').gsub(/(.{1,#{width}})( |\Z)/, "\\1\n             ")
      end

      def truncate_version_list(limit)
        suffix = lib.versions.size >= limit ? '...' : ''
        "(#{lib.versions.size} versions: #{lib.versions.reverse[0..limit].join(', ').blue}#{suffix})"
      end
    end
  end
end
