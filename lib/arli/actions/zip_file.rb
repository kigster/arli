require_relative 'action'

module Arli
  module Actions
    class ZipFile < Action
      def act
        # TODO: verify that this works if backup option is provided
        library.rm_rf!
        download!
        if File.exist?(zip_archive)
          FileUtils.rm_rf(zip_folder) if zip_folder
          unzip(zip_archive, '.')
          FileUtils.move(zip_folder, dir) if Dir.exist?(zip_folder)
        end
      rescue Exception => e
        fuck
        puts
        raise(e)
      ensure
        delete_zip!
      end

      private

      def delete_zip!
        FileUtils.rm_f(zip_archive) if File.exist?(zip_archive)
      end

      def download!
        File.write(zip_archive, Net::HTTP.get(URI.parse(library.url)))
      end

      def zip_archive
        @zip_archive ||= File.basename(library.url)
      end

      # list the contents of the archive and grab the top level folder
      def zip_folder
        @zip_folder ||= `unzip -Z1 #{zip_archive} | awk 'BEGIN{FS="/"}{print $1}' | uniq | tail -1`.chomp
      end

      def unzip(file, destination)
        `unzip -o #{file} -d #{destination}`
      end
    end
  end
end
