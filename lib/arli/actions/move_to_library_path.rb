require_relative 'action'

module Arli
  module Actions
    class MoveToLibraryPath < Action
      description 'Moves the downloaded library to the proper path, optionally creating a backup'

      def execute
        Dir.chdir(config.runtime.pwd) do

          handle_preexisting_folder(path) if exists?

          if Dir.exist?(temp_path) && !Dir.exist?(path)
            FileUtils.mkdir_p(File.dirname(path))
            ___ "current: #{Dir.pwd.yellow}\ntemp_path: #{temp_path.yellow}\nlibrary_path: #{path.yellow}\n" if debug?
            mv(temp_path, path)
          elsif Dir.exist?(path)
            raise ::Arli::Errors::InstallerError,
                  "Directory #{path} was not expected to still be there!"
          elsif !Dir.exist?(temp_path)
            raise ::Arli::Errors::InstallerError,
                  "Directory #{temp_path} was expected to exist!"
          end
        end
      end

      private

      def handle_preexisting_folder(to)
        if Dir.exist?(to)
          if abort?
            raise ::Arli::Errors::LibraryAlreadyExists, "Directory #{to} already exists"
          elsif backup?
            backup!(to)
          elsif overwrite?
            FileUtils.rm_rf(to)
          end
        end
      end

      def backup!(p)
        if Dir.exist?(p)
          backup_path = "#{p}.arli-backup-#{Time.now.strftime('%Y%m%d%H%M%S')}"
          FileUtils.mv(p, backup_path)
          print_target_dir(backup_path, 'backed up')
          if verbose?
            ___ "\nNOTE: path #{p.blue} has been backed up to #{backup_path.bold.green}\n"
          end
        end
      end

    end
  end
end
