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
      attr_accessor :sources, :headers

      def act
        find_source_files

        # so "dir" is the 'Adafruit_Unified_Sensor'
        # but we found header Adafruit_Sensor we should
        # rename the folder

        return if headers.include?(dir)
        return if sources.include?(dir)

        ___

        # if we end up setting this, we'll also move the folder.
        canonical_dir =
            if_only_one(headers) ||
            if_only_one(sources) ||
            if_header_a_substring(headers)

        if canonical_dir
          library.canonical_dir = canonical_dir
          FileUtils.rm_rf(canonical_dir) if Dir.exist?(canonical_dir)
          ___ " (#{canonical_dir.bold.green}) "
          FileUtils.mv(dir, library.canonical_dir)
        end
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
