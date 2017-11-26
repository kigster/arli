require_relative 'base'
module Arli
  module Actions
    class Backup
      attr_accessor :dir, :options

      def initialize(dir, **options)
        self.dir = dir
        self.options = options
      end

      def backup!
        if options[:copy]
          FileUtils.cp_r(dir, backup_library_path)
        else
          FileUtils.mv(dir, backup_library_path)
        end
      end

      private

      def backup_library_path
        dir + ".#{Time.now.strftime('%Y%m%d%H%M%S')}"
      end

    end
  end
end
