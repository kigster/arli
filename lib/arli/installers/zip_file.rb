require 'archive/zip'
require_relative 'base'

module Arli
  module Installers
    class ZipFile < ::Arli::Installers::Base

      def initialize(lib:, **opts)
        super(lib: lib, **opts)
        raise 'Invalid URL for this installer: ' + lib.url unless lib.url =~ /\.zip$/i
      end

      def install
        s 'unpacking zip...'

        download!
        remove_library!
        remove_library_versions!

        unzip(zip_archive, '.')

        dir = dirs_matching(lib_dir).first
        FileUtils.move(dir, lib_dir) if dir
        FileUtils.rm_f(zip_archive) if File.exist?(zip_archive)

        super
      end

      private

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
