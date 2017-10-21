require 'json'
require 'fileutils'
require 'open3'
require 'arli'
require 'arli/commands/update'

module Arli
  module Commands
    class Install < Update

      def run
        header
        all_dependencies(command, 'name', 'git')
      end

      def install_dependency(name, url)
        cmd = if Dir.exist?(name)
                if update_if_exists
                  update_dependency(name)
                else
                  raise <<-EOF
               Existing folder found for library #{name.red}. 
               Please use -u switch with 'install' command, 
               or invoke the 'update' command directly."
                        EOF
                          .gsub(/^\s+/, '')

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
