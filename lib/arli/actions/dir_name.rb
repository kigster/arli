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
      end

      private

      def set_canonical_dir!(canonical_dir)
        if canonical_dir && canonical_dir != dir
          mv(dir, canonical_dir)
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

      def find_source_files
        Dir.chdir(dir) do
          self.sources = files_with_extension('**.{cpp,c}')
          self.headers = files_with_extension('**.{h}')
        end
      end

      EXT_REGEX = /\.(cpp|h|c)$/
      EXT_CHOMP = ->(f) { f.gsub(EXT_REGEX, '') }

      def files_with_extension(pattern)
        Dir.glob(pattern).map(&EXT_CHOMP)
      end
    end
  end
end
