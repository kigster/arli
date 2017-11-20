require 'archive/zip'

module Arli
  module Installers
    class Unzipper
      class UnzipperError < StandardError;
      end

      attr_accessor :lib, :lib_dir

      def initialize(lib:)
        self.lib = lib
        self.lib_dir = lib.name.gsub(/ /, '_')
        raise 'Invalid URL for this installer: ' + lib.url unless lib.url =~ /\.zip$/i
      end

      def install
        download!
        dirs = dirs_matching(lib_dir)
        dirs.delete(lib_dir)

        # Delete old ones if any
        dirs.each { |d| FileUtils.rm_f(d) }

        unzip(zip_archive, '.')
        dir = dirs_matching(lib_dir).first
        FileUtils.move(dir, lib.name) if dir && dir != lib_dir
        FileUtils.rm_f(zip_archive)
      end

      private

      def dirs_matching(name)
        Dir.glob("#{name}*").select { |d| File.directory?(d) }
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
        `unzip #{file} -d #{destination}`
      end
    end
  end
end
