require_relative 'action'
require_relative '../helpers/system_commands'

module Arli
  module Actions
    class MoveToLibraryPath < Action

      description 'Moves the downloaded library to the proper path, optionally creating a backup'

      include ::Arli::Helpers::SystemCommands

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
    end
  end
end
