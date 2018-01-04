[![Gem Version](https://badge.fury.io/rb/arli.svg)](https://badge.fury.io/rb/arli)
[![Build Status](https://travis-ci.org/kigster/arli.svg?branch=master)](https://travis-ci.org/kigster/arli)
[![Maintainability](https://api.codeclimate.com/v1/badges/0812671b4bec27ba89b9/maintainability)](https://codeclimate.com/github/kigster/arli/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/0812671b4bec27ba89b9/test_coverage)](https://codeclimate.com/github/kigster/arli/test_coverage)

Please visit Gitter to support and a discussion of this project.

[![Gitter](https://img.shields.io/gitter/room/gitterHQ/gitter.svg)](https://gitter.im/arduino-cmake-arli/) 

# Arli

**Arli is an Arduino library manager with the ability to search libraries, install a single library, or bundle any number of libraries with the project. Arli also is a new project generator based on the `arduino-cmake` build system.**

**Arli** is a rather simple and easy to use command-line tool which offers several indispensable features that help with Arduino project development, in particular for much larger projects with many dependencies and external libraries. 

What's more, is that projects generated by Arli's `generate` command are highly portable from one system to another. Anyone can download your project build/upload with very little work.  

### Capabilities

Arli can:

 * **search for Arduino libraries** in the official public [database](http://downloads.arduino.cc/libraries/library_index.json.gz) maintained by Arduino using any of the standard [library attributes](https://github.com/arduino/Arduino/wiki/Arduino-IDE-1.5:-Library-specification) either by the exact match, or a case-insensitive regular expression, a substring, etc. 
 
 * automatically **find, download and install** of any number of third-party Arduino library dependencies, while performing a non-trivial but required [library folder name resolution](#folder-detection)

 * **maintain a consistent set of libraries** for a given project using a YAML-formatted `Arlifile`.
 
 * support libraries **that depend on other libraries**. Arli ensures the correct build/linking order.

 * **generate a new project skeleton** based on [arli-cmake](https://github.com/kigster/arli-cmake) template, which in turn relies upon [`arduino-cmake`](https://github.com/arduino-cmake/arduino-cmake) as the build environment, which builds and uploads freshly generated projects to your firmware "out of the box".

To get a sense of its feature, we invite you to watch the following screen cast:

[![asciicast](https://asciinema.org/a/155289.png)](https://asciinema.org/a/155289)

### How is Arli Different?

Arli is a fast, small, and pretty specialized command line tool (written in Ruby) that only does **four or five things very well**, and relies on other well-supported projects do their job — in particular, it relies on Arduino SDK, and `arduino-cmake` when it generates new projects.

For additional discussion, and comparison with Arduino IDE, or PlatformIO — please [read the discussion section down below](#discussion)


<a name="folder-detection"></a>

#### Automatic Folder Name Correction

Arli understands that the folder where the library is installed must be named correctly: in other words, **folder name must match the header file inside of the folder** for the library to be found.

When Arli downloads libraries in ZIP format, they are unpacked into a folder that would not resolve as an Arduino library folder without having to be renamed. Arli provides an algorithm that searches the contents of the folder for the source and header files. The name of the directory is then compared to the files found, and in most cases Arli will automatically **rename the library folder to match the main header file ** 

> For example, 'Adafruit GFX Library' is the proper name of a corresponding library, and it's ZIP archive will unpack into a folder named `Adafruit_GFX_Library-1.4.3`.  Arli will then detect that the header file inside the folder is `Adafruit_GFX.h`. In this case Arli will rename the top-level folder to `Adafruit_GFX`, and make the library valid, and its folder easily found. 


## Installation

Arli is a ruby gem, so to install it run:

```bash
gem install arli
```

You may need to use `sudo` before the command, if you are using a system-wide ruby installation.

Once installed, run `arli` with no arguments to see it's help screen.

## Usage


Arli offers several key commands, explained below:

* `arli search [ name | regex ] [ options ]`  
  [searches](#search-command) for a library by name or any attribute in the default Arduino database.

* `arli install library-name [ options ]`  
  search, and [install](#install-command) a single library if the search for the name results in one and only one match (if multiple versions of the same library exist, the latest one is installed).
    
* `arli bundle [ options ]`  
  reads a YAML-formatted `Arlifile` that defines a list of libraries, as well as (optionally) a board name and CPU, and installs all specified libraries, or as we say [bundles the project](#bundle-command). This process includes a search, download, folder name resolution, and finally installation to either a global location, or a custom location specified by a `-l` flag, or in the `Arlifile` itself.
  
  It also generates an output file in various formats, for example `json` format will generate `Arflifile.json` with full metadata about each library. 
  
  In the CMake mode, Arli generates `Arlifile.cmake`, which can be included in the main `CMakeLists.txt` file of the project to automatically build and link with the libraries.
    
* `arli generate ProjectName [ options ]`  
  [generates](#generate-command) a clean brand new C/C++/CMake project folder `ProjectName` in the current directory (or whatever is provided by `--workspace DIR`). The generated folder is a complete and nearly empty project, but one that builds, includes a sample `Arlifile`, a starting sketch file, and all of the `CMakeLists.txt` tooling you need to build and upload your project.


### Arlifile Specification

`Arlifile` is the cornerstone of this library, and so we discuss this in detail. It's a central configuration file that defines library dependencies, and also some additional metadata, such as the board and CPU, as well as the hardware libraries.

```yaml
version: 2.0.0
libraries_path: "./libraries"
lock_format: cmake
device:
  board: uno
  cpu: atmega328
  libraries:
    hardware:
      - name: Wire
    arduino:
      - name: SD
dependencies:
- name: "Adafruit GFX Library"
- name: "Adafruit LED Backpack Library"
  depends: "Adafruit GFX Library"
- name: "Adafruit Unified Sensor"
- name: "DHT sensor library"
- name: "DS1307RTC"
- name: "OneButton"
- name: "SimpleTimer"
  url: https://github.com/jfturcot/SimpleTimer.git
- name: "Time"
```

Let's review the contents:

 * **libraries_path** defines an absolute or relative (to `Arlifile`) folder where libraries are to be installed.
 
 * **lock_format** specifies the format of the output `Arlifile.<format>` after a successful `bundle` command. If you are using Arli with CMake, you will always want to have that be specified in Arlifile to save you typing :) 

 * **Device** section is optional, but can be used to specify the **Board Name** and the **Board CPU**, as well as the two types of libraries that come with Arduino SDK
   1. general **arduino** libraries, and
   2. **hardware-specific** libraries, found in a hardware-specific folder. For example, if your hardware is AVR — then they will be in the  `${ARDUINO_SDK_PATH}/hardware/arduino/avr/libraries` folder. 

 * Finally, the **dependencies** key is an array of hashes, that list third-party libraries to be installed. Here you must specify libraries by one of the [supported fields](#arlifile-libraries). Name is the most common, but it must match library name provided in the database, not the header file name.
 
   Note that you can specify `depends:` attribute, which is an array of other library names (that must also be present in the `Arlifile`). This setting only applies to CMake build.  

> NOTE: One of Arli's design goals is to make `Arlifile` a sort of a reusable "configuration" file for the project that helps make your project easily portable.

<a name='arlifile-libraries'></a>

#### Adding Libraries to `Arlifile`

You can specify libraries by providing just the `name:` (and posibly `version`) — but **the name must match exactly a library in the Arduino standard database!**  This is a critical part. 

> **EXAMPLE:** If you want to add `Adafruit_GFX.h` header, you need to find the appropriate name for this library in the database. If you know the header name, the easiest way to do that is to do the following search:
>
> ```bash
> arli search 'archiveFileName: /adafruit_gfx/i'
> ```
> 
> You will see in the output that only two libraries match:
> 
> ```
> Adafruit GFX Library                            (1.2.2)
> WEMOS Matrix Compatible With Adafruit GFX       (1.2.0)
> ```
> 
> You want to copy the name "Adafruit GFX Library" and place it in the `Arlifile` against the `name:` attribute.

You can provide the following fields in the `Arilfile` if you want the library to be found in the Arduino Library database automatically:

 * `name` should be the exact match as described above. Use double quotes if the name contains spaces.
 * `version` can be used together with the `name` to specify a particular version. When `name` is provided without `version`, the latest version is used.
 * `checksum` and `archiveFileName` can be also used as they both uniquely identify a library, however they are not very descriptive, and we suggest you simply search by these fields first, and add the library by name, which is a good convention.

#### Installing a Non-Standard Library

If a library you are using is not in the public database just provide its `name` and the `url` fields. The URL can either be a git URL, or a downloadable ZIP file. 

**Arli will use the `url` field if it's available** without trying to search for the library elsewhere.


## Commands

<a name="bundle-command"></a>

### Command `bundle`

When you run `arli bundle` in the folder with an `Arlifile`, many things happen. Below is another screenshot of running bundle:

![](docs/arli-bundle.png)

Let's break down what you see in the above screenshot: 

 * Arli reads the list of `dependencies`, and for each library without the `url` field, it performs a search by the library `name` and optionally `version`, and then it prints the found library name in blue.
 
 * The `version` that either was specified in the `Arlifile` or is the latest for this particular library is printed next, in green.
 
 * Then Arli downloads the library sources either using the URL provided, or the URL attribute of the search result. Note, that **Arli always downloads libraries into a temporary folder first.**.
 
 * Arli then scans the files inside each folder, and cleverly determines the [**canonical directory name**](#folder-detection) for each library based on the most appropriate C/C++ header file found within it. This is the name printed to the right in green.
 
 * Next, the library is moved to the new canonical name within the temporary folder, and then the canonical folder is moved into the destination library path.
 
 * If the destination folder already exists, three possible actions can happen, and are controlled with the `-e` flag:

    * the default action is to simply **overwrite the existing library folder**.
    * by using `-e [ abort | backup ]` you can optionally either abort the installation, or create a backup of the existing folder.
    
 * Upon completion of the `bundle` command, a new file will be created next to `Arlifile`: `Arlifile.<format>` where format is one of: `yaml`, `json`, `text` or `cmake`. Format can be specified with `--format <format>` or `-f` for short. The file contains different contents depending on the format. 
 
   With `json` or `yaml` formats, the file will contain a complete metadata about each installed library, obtained from the database search.
   
   With `text` format (which is the default), the result is a compact CSV file with just a couple of library attributes.
   
   With the `cmake` format, the resulting `Arlifile.cmake` is meant to be included in the `CMakeLists.txt` file of the project build with `arduino-cmake` library.

You can change the format of this file with `-f/--format` flag. 

#### CMake Integration

The CMake format is now fully supported, in tandem with `arduino-cmake` project.

Below is the resulting `Arlifile.cmake` after running `arli bundle` on the above mentioned file.

```cmake
set(ARLI_CUSTOM_LIBS_PATH "${CMAKE_CURRENT_SOURCE_DIR}/libraries")
set(ARLI_CUSTOM_LIBS
      Adafruit_GFX
      Adafruit_LEDBackpack
      Adafruit_Sensor
      DHT
      DS1307RTC
      OneButton
      SimpleTimer
      Time)
set(ARLI_ARDUINO_HARDWARE_LIBS
      Wire)
set(ARLI_ARDUINO_LIBS )
set(Adafruit_LEDBackpack_DEPENDS_ON Adafruit_GFX)
set(Adafruit_Sensor_ONLY_HEADER yes)

include(Arli)

arli_detect_serial_device("/dev/null")
arli_detect_board("uno" "atmega328")

message(STATUS "device: [${BOARD_DEVICE}], board: [${BOARD_NAME}], cpu: [${BOARD_CPU}] <<<")

arli_build_all_libraries()
```

This file only works in tandem with [`arli-cmake`](https://github.com/kister/arli-cmake) project.

See the [`generate`](#command-generate) command, which creates a new project with CMake enabled.

<a name="generate-command"></a>

### Command `generate`

This command creates a new project using the template provided by the [`arli-cmake`](https://github.com/kigster/arli-cmake) project.

```bash
$ arli generate MyClock --workspace ~/arduino/sketches
```

This command will create a brand new project under `~/arduino/sketches/MyClock`, and you should be able to build it right away:

```bash
cd ~/arduino/sketches/MyClock
bin/setup 
rm -rf build && mkdir build && cd build
cmake ..
make
make upload
```

The above steps can also be done via `bin/build src` bash script.

There is an additional `example` folder that shows the complete example that uses external libraries, and builds and compiles using CMake and Arli.

> **IMPORTANT**: Please do not forget to run `bin/setup` script. It downloads `arduino-cmake` dependency, without which the project will not build.


<a name="install-command"></a>

### Command `install`

Use this command to install a single library by either a name or URL:

Eg:

```bash
❯ arli install 'Adafruit GFX Library' -l ./libs
❯ arli install 'https://github.com/jfturcot/SimpleTimer'
```

<a name="search-command"></a>

### Command `search`

To search Arduino library database, you can use the search command.

You can search in two ways:

 1. simple substrin match of the library name
 2. complex arbitrary attribute match, that supports regular expressions and more.

`arli search AudioZero` does a simple search by name, and would match any library with 'AudioZero' in the name, such as `AudioZeroUpdated`. This search returns three results sorted by the version number:

```bash
❯ arli search AudioZero

--------------------------------------------------------------------------------
Arli (0.8.4), Command: search
Library Path: ~/Documents/Arduino/Libraries
--------------------------------------------------------------------------------

AudioZero                                       (1.1.1)    ( 3 total versions )

———————————————————————
  Total Versions : 3
Unique Libraries : 1
———————————————————————
```

The search argument can also be a ruby-syntaxed expression, that (if you know ruby)  is actually `eval`-ed into the method parameters. Here are a few examples:

You can also use regular expressions, and set maximum number of results printed by the `-m MAX` flag.

![search](docs/arli-search.png)

#### Search Output Format

Finally, you can change the output format of the search, by passing `-f <format>`, where `format` can be `short` (the default), `long`, `json`, or `yaml`.

For example, here is a how long format looks like:

```
❯ arli search 'name: /adafruit/i'  -f long

Arli (0.8.4), Command: search
Library Path: ~/Documents/Arduino/Libraries
_______________________________________________________________
Name:        Adafruit ADS1X15
Versions:    1.0.0,
Author(s):   Adafruit
Website:     https://github.com/adafruit/Adafruit_ADS1X15
Sentence:    Driver for TI's ADS1015: 12-bit Differential or 
             Single-Ended ADC with PGA and Comparator
_______________________________________________________________
Name:        Adafruit ADXL345
Versions:    1.0.0,
Author(s):   Adafruit
Website:     https://github.com/adafruit/Adafruit_ADXL345
Sentence:    Unified driver for the ADXL345 Accelerometer
.....

```

With `-m LIMIT` flag you can limit number of results. But in our case above we printed all libraries that had the word "adafruit" (case insensitively) in their official name. We could have used `version:`, or `author`, or `website`, or even `url` and `archiveFileName` fields. For complete description of available library attributes, please see the official definition of the [`library.properties`](https://github.com/arduino/Arduino/wiki/Arduino-IDE-1.5:-Library-specification#library-metadata) file.

A detailed description of the complete search functionality is documented in the library that provides it — [arduino-library](https://github.com/kigster/arduino-library#using-search). Arli uses the `arduino-library` gem behind the scenes to search, and lookup libraries.

<a name="discussion"></a>

## Discussion

### Who is Arli For?

_Arli is ideally suited for C/C++ programmers who have some basic knowledge of CMake, and who want to build larger-than-trivial projects on Arduino platform.  Arli promotes use and reuse of libraries, which help take advantage of the Object Oriented Design Patterns, decoupling your code into reusable libraries._ 

Having said that, Arli is also helpful for projects that do NOT use CMake.  It can be used purely as a library manager, or GitHub repo downloader. 

### Why not the Arduino IDE? 

Arduino IDE is not meant for professional engineers — it's a fantastic educational tool for students. And while it lacks basic features of C/C++ development it succeeds in making Arduino programming accessible to young kids and students.

### Why not Platform.IO?

[PlatformIO](http://platformio.org/) is a great "eco-system" that includes not just Arduino, but many other boards, provides integrated library manager, and Atom as the primary IDE. It's a fantastic tool for beginner/intermediate developers, much better than Arduino IDE. 

But it's not without its downsides: to some — PlatformIO feels *too heavy*. It comes with a gazillion additional features you'll never use and it tries to be too much all at once. Perhaps for some people — it can be a feature. But for the author and other members of the Arduino dev community, PlatformIO design goes against the fundamental principals of [Unix Philosophy](https://en.wikipedia.org/wiki/Unix_philosophy), which promotes a minimalist, modular software development delegated to specialized commands that can be all interconnected (think `grep`, `awk`, `sort`, `uniq`). 


### More Reasons Why Arli is Needed

Arli is both an *Arduino Library Manager* and a project generator. If you are using Arduino IDE you may be wondering **why is this needed?**

 * Well, for one, Arli can "bundle" libraries not just from the official Arduino database, but also from individual Github URLs. There are thousands of libraries of high quality, that for one reason or another did not make it into the official database.

 * Arduino still haven't come up with a way to automatically document project's dependencies on a set of libraries. I believe the best you've got is having to list libraries in comments, and then install each manually. With Arli you can automate this entire process.

 * [Not everyone likes using Arduino IDE](https://kig.re/2014/08/02/arduino-ide-alternatives.html). So this tool is, perhaps, aimed more at the professional programmers, wanting to build applications that tend to be on a complex side, and rely on multiple third party libraries. Boards like Teensy have a lot more RAM than Arduino UNO and clones, and so it can support much larger projects with dozens of libraries linked in with the firmware.

 * One of Arli's design goals is to provide a bridge between the [arduino-cmake](https://github.com/arduino-cmake/arduino-cmake) project, which provides an alternative build system, and is compatible with numerous IDEs such as [Atom](https://atom.io), [JetBrains CLion](https://www.jetbrains.com/clion/), [Visual Studio Code](https://code.visualstudio.com/), or even [Eclipse](https://eclipse.org).


### Working with Complex Projects

Arli shines when you need to build a complicated and multi-dependency project using an Arduino compatible board such as [Teensy](https://www.pjrc.com/teensy/), which has 16x more RAM than the Arduino UNO, and therefore allows you to take advantage of many more third-party Arduino libraries at once within a single project.

> A few years ago the author built a complex project called [**Filx Capacitor**](https://github.com/kigster/flix-capacitor), which relied on **ten** external libraries. Managing these dependencies was very time-consuming. Asking someone else to build this project on their system was near impossible. Not just that, but even for the author himself, after taking some time off and returning to the project — it was still difficult to figure out why it was suddenly refusing to build. So many things could have gone wrong. 
>
> This is the problem Arli (together with the very powerful `arduino-cmake` project) attempts to solve. Your project's dependencies can be cleanly defined in a YAML file called `Arlifile`, together with an optional board name and a CPU. Next, you add a bunch of C/C++ files to the folder, update `CMakeLists.txt` file and rebuild the project, upload the firmware, or connect to the serial port. See [arli-cmake](https://github.com/kigster/arli-cmake#manual-builds) for more information. 


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kigster/arli.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
