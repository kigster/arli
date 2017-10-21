require 'json'
require 'fileutils'
require 'open3'
require 'arli'

module Arli
  module Commands
    class Base
      attr_accessor :lib_path, :json_file

      def initialize(options)
        self.lib_path  = options[:lib_home]
        self.json_file = options[:arli_json]
        setup
      end

      def run
        raise NameError, 'Internal Error: #run is an abstract method on Base'
      end

      protected

      def install_dependencies
        for_each_dependency do |dep|
          begin
            install_library(dep['name'], dep['git'])
          rescue Exception => e
            error("error while installing #{dep.inspect.green}", e)
            return
          end
        end
      end

      def install_library(name, url)
        info 'Installing ' + name.yellow
        cmd = unless Dir.exist?(name)
                "git clone -v #{url} #{name} 2>&1"
              else
                "cd #{name} && git pull --rebase 2>&1"
              end

        info cmd.bold.green

        o, e, s = Open3.capture3(cmd)
        puts o if o
        puts e.red if e
        return s
      end

      def for_each_dependency(&_block)
        dependencies['dependencies'].each do |dependency|
          Dir.chdir(lib_path) do
            yield(dependency)
          end
        end
      end

      def dependencies
        @deps ||= begin
          JSON.load(File.read(json_file))
        rescue Errno::ENOENT => e
          error("File #{json_file.bold.yellow} could not be found!", e)
          { 'dependencies' => [] }
        end
      end

      def error(msg, exception = nil)
        printf 'Runtime Error: '.bold.red + "\n#{msg}!\n"
        if exception
          puts
          printf 'Exception: '.red + "\n#{exception.inspect.red}!\n\n"
        end
        puts
      end

      def info(msg, header = nil)
        puts header.bold.blue if header
        puts (header ? '    ' : '') + msg
      end

    end
  end
end
