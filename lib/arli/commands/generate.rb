require 'json'
require 'arli'
require 'net/http'
require_relative 'base'
require_relative '../arli_file'
require_relative '../helpers/system_commands'
require 'forwardable'
require 'arduino/library'
module Arli
  module Commands
    class Generate < Base

      include ::Arduino::Library
      include ::Arli::Helpers::SystemCommands

      extend Forwardable
      def_delegators :@settings, :project_name, :project_name=, :workspace, :workspace=, :libs, :libs=, :template_repo

      attr_accessor :settings, :dir, :libraries

      def setup
        config.generate.project_name = config.runtime.argv.first

        self.settings = config.generate
        self.libraries = []

        (settings.libs || []).each do |lib|
          library = find_library({ name: lib }, version: :latest)
          if library
            self.libraries << library
          else
            raise ::Arli::Errors::LibraryNotFound, "Can not find library by name #{lib}"
          end
        end

        raise ::Arli::Errors::RequiredArgumentsMissing, 'Project name is required' unless project_name
        raise ::Arli::Errors::RequiredArgumentsMissing, 'Template Repo is missing' unless template_repo

        self.dir = settings.workspace + '/' + project_name
        handle_preexisting_folder(dir) if Dir.exist?(dir)
        FileUtils.mkdir_p(workspace) unless Dir.exist?(workspace)
      end

      def run
        Dir.chdir(workspace) do
          run_with_info(
              "Grabbing the template from\n • #{template_repo.bold.green}...",
              "git clone -v #{template_repo} #{project_name} 2>&1"
          )
          Dir.chdir(project_name) do
            FileUtils.rm_rf('.git')
            FileUtils.rm_rf('example')
            run_with_info(
                "Configuring the new project #{project_name.bold.yellow}",
                'git init .'
            )
            run_with_info('Customizing your README and other files...')

            rename_files!

            configure_template!
            configure_arlifile!

            configure_main!

            run_with_info(
                'Running setup of the dependencies...',
                'bin/setup'
            )
            run_with_info("The project #{project_name.bold.yellow} is ready.\n" +
                              'Follow README.md for build instructions.')
          end
        end
        __pt hr
      end

      def run_with_info(message, command = nil)
        indent     = '    '
        ok_indent  = indent + ' ✔  '.green
        err_indent = indent + ' X   '.red
        info("\n" + message.magenta)
        return unless command
        info(indent + command.bold.yellow)
        o, e, s = run_system_command(command)
        info(ok_indent + o.chomp.gsub(/\n/, "\n#{ok_indent}").blue) if o && o.chomp != ''
        warn(err_indent + +e.chomp.gsub(/\n/, "\n#{err_indent}").red) if e && e.chomp != ''
      end

      def additional_info
        "\nGenerating project #{project_name.bold.green} into #{workspace.bold.yellow}\n" +
            "Template: #{template_repo.bold.red}\n"
      end

      private

      def configure_arlifile!
        arli_config = YAML.load(File.read('src/Arlifile'))
        arli_config['dependencies'] = []

        (libraries || []).each do |library|
          arli_config['dependencies'] << { 'name' => library.name, 'version' => library.version }
        end

        File.open('src/Arlifile', 'w') do |f|
          f.write(YAML.dump(arli_config))
        end
      end

      def configure_main!
        template = File.read(File.expand_path('../main.cpp.erb', __FILE__))
        main = ERB.new(template).result(binding)
        require 'erb'
        File.open("src/#{project_name}.cpp", 'w') do |f|
          f.write(main)
        end
      end

      def rename_files!
        FileUtils.mv('README.md', 'README-Arli-CMake.md')
        run_with_info('Updating CMakeLists.txt file...',
                      "sed -E -i '' 's/example/src/g' CMakeLists.txt")
        run_with_info('Updating CMakeLists.txt files...',
                      "find . -type f -name CMakeLists.txt -exec sed -E -i '' 's/MyProject/#{project_name}/g' {} \\; ")
        Dir.chdir('src') do
          FileUtils.rm_f('MyProject.cpp')
        end
      end

      def configure_template!
        template = File.read(File.expand_path('../readme.md.erb', __FILE__))
        @project_name = config.generate.project_name
        readme = ERB.new(template).result(binding)
        require 'erb'
        File.open('README.md', 'w') do |f|
          f.write(readme)
        end
      end
    end
  end
end
