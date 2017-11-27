require_relative 'action'

module Arli
  module Actions
    class Backup < Action

      def act(**options)
        return false unless exists?

        if backup_action.abort
          raise Arli::Errors::LibraryAlreadyExists, path
        elsif backup_action.backup
          FileUtils.mv(path, backup_library_path)
        elsif backup_action.overwrite
          library.rm_rf!
        end
      end

      def backup_action
        config.install.if_exists
      end

      private

      def backup_library_path
        path + ".#{Time.now.strftime('%Y%m%d%H%M%S')}"
      end
    end
  end
end
