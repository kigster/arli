require 'json'
require 'fileutils'
require 'open3'
require 'arli'
require 'arli/commands/update'

module Arli
  module Commands
    class Install < Update

      def run
        all_dependencies(command, 'name', 'url')
      end

      def install_dependency(name, url)
        cmd = if Dir.exist?(name)
                if abort_if_exists
                  raise <<-EOF
                               Existing folder found for library #{name.red}. 
                               Please use -u switch with 'install' command, 
                               or invoke the 'update' command directly."
                                EOF
                          .gsub(/^\s+/, '')

                else
                  update_dependency(name)
                end
              else
                "git clone -v #{url} #{name} 2>&1"
              end
        yield(cmd) if block_given?
        cmd
      end
    end

  end
end
