require_relative '../output'

module Arli
  module Installers
    class Base
      include Arli::Output

      attr_accessor :lib, :lib_dir, :lib_path

      def initialize(lib:, lib_path:)
        self.lib = lib
        self.lib_path = lib_path
        self.lib_dir = lib.name.gsub(/ /, '_')
      end

      def install
        print_success
      end

      protected

      def target_lib_path
        "#{lib_path}/#{lib_dir}"
      end

      def exists?
        Dir.exist?(target_lib_path)
      end

      def remove_library!
        FileUtils.rm_rf(lib_dir)
      end

      def remove_library_versions!
        dirs = dirs_matching(lib_dir)
        dirs.delete(lib_dir) # we don't want to delete the actual library
        dirs.each { |d| FileUtils.rm_f(d) }
      end

      def dirs_matching(name)
        Dir.glob("#{name}*").select { |d| File.directory?(d) }
      end
    end
  end
end
