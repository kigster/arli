require 'json'
require 'fileutils'
require 'open3'
require 'arli'

module Arli
  module Commands

    class Install
      attr_accessor :lib_path, :json_file

      def initialize(lib_home: ::Arli::DEFAULT_LIBRARY_PATH,
                     arli_json: ::Arli::DEFAULT_JSON_FILE)

        self.lib_path  = lib_home
        self.json_file = arli_json
        setup
      end

      def run
        libs = JSON.load(File.read(json_file))
        puts "Installing into #{lib_path.bold.green}"

        Dir.chdir(lib_path) do
          libs['dependencies'].each do |dependency|
            name = dependency['name']
            url  = dependency['git']
            printf 'processing library: ' + name.yellow.bold + "\n"
            unless Dir.exist?(name)
              cmd = "git clone -v #{url} #{name} 2>&1"
            else
              cmd = "cd #{name} && git pull --rebase 2>&1"
            end
            puts 'command: ' + cmd.bold.blue
            o, e, s = Open3.capture3(cmd)
            puts o if o
            puts e.red if e
          end
        end
      end

      private

      def setup
        FileUtils.mkdir_p(lib_path)
        yield self if block_given?
        self
      end
    end
  end
end
