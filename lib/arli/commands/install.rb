require 'json'
require 'fileutils'
require 'open3'
require 'arli'
require 'arli/commands/update'

module Arli
  module Commands
    class Install < Update

      def command_for_dependency(lib)
        cmd = if Dir.exist?(lib.name)
                if abort_if_exists
                  raise <<-EOF
                               Existing folder found for library #{lib.name.red}. 
                               Please use -u switch with 'install' command, 
                               or invoke the 'update' command directly."
                        EOF
                          .gsub(/^\s+/, '')

                else
                  super(lib)
                end
              else
                "git clone -v #{lib.url} #{lib.name} 2>&1"
              end
        cmd
      end
    end
  end
end
