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
          run_with_info(
              "grabbing the template from\n • #{template_repo.bold.green}...",
              "git clone -v #{template_repo} #{project_name} 2>&1"
          )
          Dir.chdir(project_name) do
            FileUtils.rm_rf('.git')
            FileUtils.rm_rf('example')
            run_with_info(
                "configuring the new project #{project_name.bold.yellow}",
                'git init .'
            )
            run_with_info('customizing your README and other files...')
            rename_files!
            configure_template!
            run_with_info(
                'running bin/build — to setup and build the project',
            )
            system('bin/build setup')
            puts '[OK]'.bold.green
          end
        end
      end

      def run_with_info(message, command = nil)
        info("\n" + message.cyan)
        return unless command
        o, e, s    = run_system_command(command)
        ok_indent  = '    ✔ '.green
        err_indent = '    x '.red
        info(ok_indent + o.chomp.gsub(/\n/, "\n#{ok_indent}").blue) if o && o.chomp != ''
        warn(err_indent + +e.chomp.gsub(/\n/, "\n#{err_indent}").red) if e && e.chomp != ''
      end

      def additional_info
        "\nGenerating project #{project_name.bold.green}\nDestination: #{workspace.bold.yellow}\n"
      end

      private

      def rename_files!
        FileUtils.mv('README.md', 'README-Arli-CMake.md')
        Dir.chdir('src') do
          FileUtils.mv('MyProject.cpp', "#{project_name}.cpp")
          run_system_command "sed -i 's/MyProject/#{project_name}/g' CMakeLists.txt"
        end
        run_system_command "sed -i 's/MyProject/#{project_name}/g' CMakeLists.txt"
      end

      def configure_template!
        File.open('README.md', 'w') do |f|
          f.write <<-EOF
          

> This project has been auto-generated using:
>  * [arli](https://github.com/kigster/arli) Arduino toolkit, and using the `generate` command. Thank you for using Arli!
>  * [arli-cmake](https://github.com/kigster/arli-cmake) is the template project that was used as a source for this one.
>  * [arduino-cmake](https://github.com/arduino-cmake/arduino-cmake) is the CMake-based build system for Arduino projects.
>
> There is a discussion board for Arli/CMake-based projects. Please join if you have any questions or suggestions!
> [![Gitter](https://img.shields.io/gitter/room/gitterHQ/gitter.svg)](https://gitter.im/arduino-cmake-arli/)


# #{project_name}

**TODO: Please update this README to reflect information about you project. :)** 

## Prerequisites

 * On a Mac, you always need to run `xcode-select --install` before you can do any development. You must have `git` installed;

 * Requires [CMake](https://cmake.org/download/)

 * Requires [Arduino IDE](https://www.arduino.cc/en/Main/Software) or an SDK, either for [Mac](https://downloads.arduino.cc/arduino-1.8.5-macosx.zip) or [Linux](https://downloads.arduino.cc/arduino-1.8.5-linux.zip) installed;

 * Requires ruby, 2.3 or 2.4+ installed. On a Mac's Terminal, run `ruby --version`. If for some reason you don't have it installed, the `bin/setup` script will prompt you to install it.

## Building #{project_name}
 
### Using the BASH Helper `bin/build`

This project contains a BASH script that can automate your setup and build process. The following script takes care of most dependencies, including a missing Ruby.

```bash
$ cd ~/workspace/#{project_name}
$ bin/build [ setup | clean | make-flags ]
```

You should see a bunch of output, and upon completion, run `arli` without arguments to see if the command got installed and shows you proper help message. If you get `command not found`, please `[sudo] gem install arli --no-ri --no-rdoc`. Add sudo if your ruby installation is the system one, ie, `which ruby` returns `/usr/bin/ruby`.


### Manual Build

If you prefer to have more control over the build, you can of course build manually, 
and manage `CMakeLists.txt` however you want. 

Once you've run the setup, the manual build is:

```bash
$ cd ~/workspace/#{project_name}
$ rm -rf build && mkdir -p build && cd build
$ cmake ..
$ make                          # this builds the image
$ make upload                   # this uploads it to the device
$ # this next command opens a serial port monitor inside a screen session
$ make #{project_name}-serial   
```

#### Customizing the Build

You can use environment variables to set the board, CPU and the port. Simply prefix the following variables before you run `cmake ..`

```bash
$ rm -rf build
$ mkdir -p build
$ cd build
$ BOARD_NAME=nano \\
  BOARD_CPU=atmega328p \\
  BOARD_DEVICE=/dev/tty.usbserial-DA00WXFY \\
  cmake ..
```

### Adding External Libraries

Your repo contains `Arlifile` inside the `src` folder. Please [read the documentation](https://github.com/kigster/arli#command-bundle) about the format of `Arlifile`.

Go ahead and edit that file, and under `dependencies:` you want to list all of your libraries by their exact name, and an optional version. 

The best way to do that is to **first search for the library** using the `arli search terms` command. Once you find the library you want, just copy it's name as is into `Arlifile`. If it contains spaces, put quotes around it.

If the library is not in the official database, just add it with a name and a url. Arli will use the url field to fetch it.

To verify that your Arlifile can resolve all libraries, please run `arli bundle` inside the `src` folder. If Arli suceeds, you've got it right, and the `libraries` folder inside `src` should contain all referenced libraries.

### Adding Source Files

You will notice that inside `src/CMakeLists.txt` file, there is a line:

```cmake
set(PROJECT_SOURCES #{project_name}.cpp)
```

If you add any additional source files or headers, just add their names right after, separated by spaces or newlines. For example:

```cmake
set(PROJECT_SOURCES 
  #{project_name}.cpp
  #{project_name}.h
  helpers/Loader.cpp
  helpers/Loader.h
  config/Configuration.h
)
```

The should be all you need to do add custom logic and to rebuild and upload the project.

## Where to get Support?

Please feel free to file bug reports and submit pull requests on GitHub — [https://github.com/kigster/arli-cmake](https://github.com/kigster/arli-cmake) is the project URL, and this is the [issues](https://github.com/kigster/arli-cmake/issues) URL.

## License

The original project is distributed as open source, under the terms of the [MIT License](http://opensource.org/licenses/MIT). 

However, feel free to change the license of your project, as long as you provide the credit to the original.

Thanks!
Good luck!


          EOF
        end
      end
    end
  end
end
