require 'json'
require 'arli'
require 'net/http'
require_relative 'base'
require_relative '../arli_file'
require_relative '../helpers/system_commands'
require 'forwardable'
module Arli
  module Commands
    class Generate < Base
      include ::Arli::Helpers::SystemCommands

      extend Forwardable
      def_delegators :@settings, :project_name, :project_name=, :workspace, :workspace=, :libs, :libs=, :template_repo

      attr_accessor :settings, :dir


      def setup
        config.generate.project_name = config.runtime.argv.first

        self.settings = config.generate

        raise ::Arli::Errors::RequiredArgumentsMissing, 'Project name is required' unless project_name
        raise ::Arli::Errors::RequiredArgumentsMissing, 'Template Repo is missing' unless template_repo

        self.dir = settings.workspace + '/' + project_name
        handle_preexisting_folder(dir) if Dir.exist?(dir)
        FileUtils.mkdir_p(workspace) unless Dir.exist?(workspace)
      end

      def run
        Dir.chdir(workspace) do
          run_system_command "git clone -v #{template_repo} #{project_name.downcase} 2>&1"
          Dir.chdir(project_name.downcase) do
            FileUtils.rm_rf('.git')
            run_system_command 'git init .'
            run_system_command 'bin/setup'
            configure_template!
            rename_files!
          end
        end
      end

      def additional_info
        "Generating project #{project_name.bold.green} into #{workspace.bold.yellow}..."
      end

      private

      def rename_files!
        Dir.chdir('src') do
          FileUtils.mv('MyProject.cpp', "#{project_name}.cpp")
          run_system_command "sed -i 's/MyProject/#{project_name}/g' CMakeLists.txt"
        end
      end

      def configure_template!
        File.open('README.md', 'w') do |f|
          f.write <<-EOF

# #{project_name}

Please refer to the README for the template project, available here:
[arli-cmake](#{template_repo}).

## Usage

Let's cd into the project folder:

```bash
cd #{project_name}
```

The directory structure should look as follows:

```
  #{project_name}
     |
     |__ bin/
     |   |___ setup
     |   |___ build
     |
     |__ cmake/
     |   |___ Arli.cmake
     |   |___ ArduinoToolchain.cmake          <———— provided by arduino-cmake project
     |   |___ Platform/                       <———— provided by arduino-cmake project
     |
     |__ src/
     |   |___ Arlifile
     |   |___ CMakeLists.txt
     |   |___ #{project_name}.cpp
     |
     |__ example/
         |___ Arlifile
         |___ CMakeLists.txt
         |___ Adafruit7SDisplay.cpp
```

You might need to run `bin/setup` first to ensure you have all the dependencies. 

Once you do that, you can build any of the source folders (i.e. either `src` or `example`) by
running `bin/build src` or `bin/build example`.

### Building Manually

The process to build and upload manually is super simple too:

```bash
cd src
rm -rf build && mkdir build && cd build
cmake ..
make 
make upload
```

          EOF
        end
      end
    end
  end
end
