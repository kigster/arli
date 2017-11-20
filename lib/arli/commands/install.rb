require 'json'
require 'fileutils'
require 'open3'
require 'arli'
require 'arli/commands/update'
require 'arli/errors'

module Arli
  module Commands
    class Install < Update

      def git_command(lib)
        "git clone -v #{lib.url} #{lib.name} 2>&1"
      end
    end
  end
end
