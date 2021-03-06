# frozen_string_literal: true

require_relative 'action'

module Arli
  module Actions
    # The purpose of this action is to fix the directory
    # name of the library, that's possibly incorrect.
    # For example, library "Adafruit Unified Sensor" installs
    # into the folder 'Adafruit_Unified_Sensor'
    # while the source files inside are 'Adafruit_Sensor.h'
    # This action renames invalid library folders based on the
    # source files found inside.
    class DirName < Action
      description 'Auto-detects the canonical library folder name'

      attr_accessor :sources, :headers

      def execute
        find_source_files

        # so "dir" is the 'Adafruit_Unified_Sensor'
        # but we found header Adafruit_Sensor we should
        # rename the folder

        if headers.include?(dir) || sources.include?(dir)
          set_canonical_dir!(dir)
        else
          candidate =
            if_only_one(headers) ||
            if_only_one(sources) ||
            if_header_a_substring(headers)

          set_canonical_dir!(candidate)
        end

        if if_no(sources) && if_have(headers)
          library.headers_only = true
        end
      end

      private

      def set_canonical_dir!(canonical_dir)
        if canonical_dir && canonical_dir != dir
          # if they are match case insensitively, we may be
          # on a mac where these are considered the same
          if dir =~ /^#{canonical_dir}$/i
            mv(dir, canonical_dir + '.temp')
            mv(canonical_dir + '.temp', canonical_dir)
          else
            mv(dir, canonical_dir)
          end
          library.canonical_dir = canonical_dir
        else
          library.canonical_dir = dir
        end
        print_target_dir(library.canonical_dir, 'installed to')
      end

      def if_header_a_substring(files)
        files.find { |file| dir.start_with?(file) }
      end

      def if_only_one(file_names)
        if file_names.size == 1 && file_names.first != dir
          file_names.first
        end
      end

      def if_no(file_names)
        file_names.nil? || file_names.empty?
      end

      def if_have(file_names)
        file_names && !file_names.empty?
      end

      def find_source_files
        Dir.chdir(dir) do
          self.sources = files_with_extension('**.{cpp,c}')
          self.headers = files_with_extension('**.{h}')
        end
      end

      EXT_REGEX = /\.(cpp|h|c)$/.freeze
      EXT_CHOMP = ->(f) { f.gsub(EXT_REGEX, '') }

      def files_with_extension(pattern)
        Dir.glob(pattern).map(&EXT_CHOMP)
      end
    end
  end
end
