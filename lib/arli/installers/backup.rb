require_relative 'base'
module Arli
  module Installers
    class Backup < Base

      def backup_lib_path
        target_lib_path + ".#{Time.now.strftime('%Y%m%d%H%M%S')}"
      end

      def backup!
        FileUtils.cp_r(target_lib_path, backup_lib_path) if exists?
      end

      alias install backup!

    end
  end
end
