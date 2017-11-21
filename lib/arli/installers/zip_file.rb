require 'archive/zip'

module Arli
  module Installers
    class ZipFile
      attr_accessor :lib, :lib_dir

      def initialize(lib:)
        self.lib     = lib
        self.lib_dir = lib.name.gsub(/ /, '_')
        raise 'Invalid URL for this installer: ' + lib.url unless lib.url =~ /\.zip$/i
      end

      def install
        download!

        remove_library!
        remove_library_versions!

        unzip(zip_archive, '.')

        dir = dirs_matching(lib_dir).first

        FileUtils.move(dir, lib_dir) if dir

        FileUtils.rm_f(zip_archive) if File.exist?(zip_archive)
      end

      def remove_library!
        FileUtils.rm_rf(lib_dir)
      end

      def remove_library_versions!
        dirs = dirs_matching(lib_dir)
        dirs.delete(lib_dir) # we don't want to delete the actual library
        dirs.each { |d| FileUtils.rm_f(d) }
      end

      private

      def dirs_matching(name)
        Dir.glob("#{name}*").select { |d| File.directory?(d)  }
      end

      def zip_archive
        @zip_archive ||= File.basename(lib.url)
      end

      def download!
        File.write(zip_archive, Net::HTTP.get(URI.parse(lib.url)))
      end

      # def unzip(file, destination)
      #   Archive::Zip.extract(file, destination, on_error: :skip)
      # end
      def unzip(file, destination)
        `unzip -o #{file} -d #{destination}`
      end
    end
  end
end
