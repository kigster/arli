require_relative 'action'

module Arli
  module Actions
    class UnzipFile < Action
      description 'Downloads and unzip remote ZIP archives'
      check_command 'unzip -h'
      check_pattern 'extract files to pipe'

      def execute
        return if library.url.nil?
        return if library.url !~ /\.zip$/i

        download!
        move_in_place!
      rescue Exception => e
        fuck
        raise(e)
      ensure
        delete_zip! rescue nil
      end

      private

      def move_in_place!
        if File.exist?(zip_archive)
          FileUtils.rm_rf(top_dir_inside_zip) if top_dir_inside_zip
          unzip(zip_archive, '.')
          FileUtils.move(top_dir_inside_zip, dir) if Dir.exist?(top_dir_inside_zip)
        end
      end

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
      def top_dir_inside_zip
        @zip_folder ||= `unzip -Z1 #{zip_archive} | awk 'BEGIN{FS="/"}{print $1}' | uniq | tail -1`.chomp
      end

      def unzip(file, destination)
        `unzip -o #{file} -d #{destination}`
      end
    end
  end
end
