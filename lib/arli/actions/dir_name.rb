require_relative 'base'

module Arli
  module Actions
    class DirName < Base

      attr_accessor :source_files

      def install
        find_source_files!

        return if source_files.include?(lib_dir)

        source_files.each do |f|
          if lib_dir.start_with?(f) || (lib.url && lib.url.end_with?(f))
            FileUtils.rm_rf(f) if Dir.exist?(f)
            FileUtils.mv(lib_dir, f)
            self.lib_dir = f
            break
          end
        end
      end

      def find_source_files!
        Dir.chdir(lib_dir) do
          self.source_files = Dir.glob('*.{cpp,c,h}').map{ |f| f.gsub(/\.(cpp|h|c)$/, '') }
        end
      end
    end
  end
end
