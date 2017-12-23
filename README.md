[![Gem Version](https://badge.fury.io/rb/arli.svg)](https://badge.fury.io/rb/arli)
[![Build Status](https://travis-ci.org/kigster/arli.svg?branch=master)](https://travis-ci.org/kigster/arli)
[![Maintainability](https://api.codeclimate.com/v1/badges/0812671b4bec27ba89b9/maintainability)](https://codeclimate.com/github/kigster/arli/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/0812671b4bec27ba89b9/test_coverage)](https://codeclimate.com/github/kigster/arli/test_coverage)

### Discussion

Please head over to Gitter to discuss this project.

[![Gitter](https://img.shields.io/gitter/room/gitterHQ/gitter.svg)](https://gitter.im/arduino-cmake-arli/) 

___

> Arli should work in any Unix environment. If you are on Windows, and need support —  please [let us know](https://gitter.im/arduino-cmake-arli/).
> 
> See also "sister project" [Arli-CMake](https://github.com/kigster/arli-cmake).

___    

# Arli

**Arli** is an *awesomely simple and very easy to use Arduino Library Manager*. If you are using Arduino IDE you may be wondering **why is this needed?**

 * Well, for one, Arli can "bundle" libraries not just from the official Arduino database, but also from individual Github URLs. There are thousands of libraries of high quality, that for one reason or another did not make it into the official database.

 * Arduino still haven't come up with a way to automatically document project's dependencies on a set of libraries. I believe the best you've got is having to list libraries in comments, and then install each manually. With Arli you can automate this entire process.
 * [Not everyone likes using Arduino IDE](https://kig.re/2014/08/02/arduino-ide-alternatives.html). So this tool is, perhaps, aimed more at the professional programmers, wanting to build applications that tend to be on a complex side, and rely on multiple third party libraries. Boards like Teensy have a lot more RAM than Arduino UNO and clones, and so it can support much larger projects with dozens of libraries linked in with the firmware.
 * One of Arli's design goals is to provide a bridge between the [arduino-cmake](https://github.com/arduino-cmake/arduino-cmake) project, which provides an alternative build system, and is compatible with numerous IDEs such as [Atom](https://atom.io), [JetBrains CLion](https://www.jetbrains.com/clion/), [Visual Studio Code](https://code.visualstudio.com/), or even [Eclipse](https://eclipse.org).

## Overview

Arli allows your Arduino projects to be portable by including a YAML file called `Arlifile` at the top of your project, that defines your project's Arduino library dependencies.

You can use the command `arli bundle` in the project's root directory to search, download and install all dependent libraries defined in the `Arlifile`. You can specify libraries by name and version, or you can omit the version to install the latest one.  You can install libraries to a nested project folder, or a shared custom location where you keep all of your Arduino Libraries, and do it all consistently and reliably over and over again.

Below is an example of an actual `Arlifile` for a [Wall Clock](https://github.com/kigster/arduino-wallclock) project, which is a gorgeous wall clock equipped with a large and bright 7-Segment LED Display that dims automatically when it's dark in the room. In addition, the clock is equipped with multple sensors, a potentiometer, and a rotatary knob for changing time and brightness. This is not a simple project and it has nine library dependencies:

![](docs/arlifile.png)

Next, below is a screenshot of running `arli bundle` inside of that with the above `Arlifile`. We install into the default libraries folder `~/Documents/Arduino/Libraries`:

![](docs/arli-in-action.png)

Let's break down what you see on the above screenshot: 

 * First Arli prints the header, containing Arli version, the command, as well as the destination library path that the libraries are going to get installed to.
 * Next, Arli is looping, and for each library without the `url` field, it performs a search by the library `name` (and optionally its `version`), and then it prints the resulting library's name in blue. 
 * The `version` that either was specified in the `Arlifile`, or is the latest for this library is printed next, in green. 
 * Then Arli downloads the library sources either using the URL provided, or the URL attribute of the search result. Note, that **Arli always downloads libraries into a temporary folder first, always!**. It then scans the files inside, and determines the *canonical directory name* for the given library based on the most appropriate C/C++ header file. The library is first moved to this new name within the temporary folder, and the resulting directory is finally moved into the library path, while also handling the use-case where the library's canonical folder may already exist in the destination. There are three possible actions in this case that can be taken:

 * the silent default action is to simply **overwrite the existing library folder**.
 * by using `-e [ abort | backup ]` you can optionally do the following: 
   * With the `abort` option, the first time an existing library is encountered, the entire command is halted, and an exception is thrown.
   * With the `backup` option, the old library folder is moved by adding an extension `.arli-backup-<TIMESTAMP>`.
   

Note that `-f yaml` specifies the format of the 'lock' file (`Arlifile.<format>`). So in this case our `Arlifile.yaml` will contain all library details obtained from the central database in YAML format. 

### How Does It Work?

In a nutshell, Arli relies on the publicly available database of the vast majority of public Ardiuino libraries. This database is maintained by Arduino themselves, and is a [giant gzipped JSON file](http://downloads.arduino.cc/libraries/library_index.json.gz). Arli automatically downloads and caches the index on a local file system, and then lets you search and install libraries using either a simple name search, or more sophisticated ruby-like syntax that supports searching for ANY attribute as an equal match, or a regular expressions, or even a [Proc](http://ruby-doc.org/core-2.4.2/Proc.html).

Sometimes, however, an Arduino library you use may not part of the main database. No problem! Just add the `url:` attribute together with the library name to `Arlifile`. The URL can either be a Github URL, or a URL to a downloadable ZIP file. Arli will figure out the rest. 

<a name="folder-detection"></a>

#### Automatic Folder Name Correction

Arli understands that the folder where the library is installed must be named correctly: in other words, **folder name must match the header file inside of the folder** for the library to be found.

When Arli downloads libraries in ZIP format, they are unpacked into folder that are named differently. Arli will then search that folder for the source and header files. The name of the directory is then compared to the files found, and in some cases Arli will automatically **rename the library folder to match the main header file.**. 

> For example, 'Adafruit GFX Library' is the proper name of a corresponding library, and it's ZIP archive will unpack into a folder named `Adafruit_GFX_Library-1.4.3`.  Arli will then detect that the header file inside the folder is `Adafruit_GFX.h`. In this case Arli will rename the top-level folder to `Adafruit_GFX`, and make the library valid, and its folder easily found. 

### Other Commands

Arli provides several additional commands, described in details down below.

 * You can [search](#search-command) the offical library using any attribute of the library tested against a string, or a regular expression, or even a Ruby Proc if you know how to write them.
 
 * You can also install a single library with [install](#install-command), in which case there is no `Arlifile` or a lock file.

## Usage

Run `arli --help` for more information:

```bash
Usage:
    arli options
    arli command [ options ]

    -A, --print-attrs      prints full list of available library
                           attributes that can be used in search strings.

    -C, --no-color         Disable any color output.
    -D, --debug            Print debugging info.
    -t, --trace            Print exception stack traces.
    -v, --verbose          Print more information.
    -q, --quiet            Print less information.
    -V, --version          Print current version and exit
    -h, --help             prints this help

Available Commands:
    search       — Search standard Arduino Library Database with over 4K entries
    bundle       — Installs all libraries specified in Arlifile
    install      — Installs a single library either by searching, or url or local ZIP

See arli command --help for more information on a specific command.

arli (0.9.0) © 2017 Konstantin Gredeskoul, MIT License.
```

<a name="command-bundle"></a>

### Command `bundle`

Use this command to install Arduino libraries defined in the `Arlifile` yaml file.

![](docs/arlifile.png)

There are two main categories of libraries you will be installing:

 1. One of the officially registered in the [Arduino official library database](http://downloads.arduino.cc/libraries/library_index.json.gz), which is a giant gzipped JSON file. Arli will download and cache this file locally, and use it to find libraries. 

 2. Using the `:url` field that links to either a remote ZIP file, or a Github Repo.
 
> When using the public database, which at the time of this writing contains 1220 unique libraries, spanning 4019 separate versions. when the remote file's size changes, will Arli automatically detects that by issuing a `HEAD` HTTP request, and after comparing the size to the locally cached version, it might decide to re-download it. 
> 
> Note that this functionality is provided by the "sister" Ruby gem called [`arduino-library`](https://github.com/kigster/arduino-library), which essentially provides most of the underlying library-specific functionality.
 

#### Installing from the Database

You can specify libraries by providing just the `name:` (and posibly `version`) — the name must match exactly a library in the Arduino standard 

You can provide the following fields in the `Arilfile` if you want the library to be found in the Arduino Library database:

 * `name` should be the exact match. Use double quotes if the name contains spaces.
 * `version` can be used together with the `name` to specify a particular version. When `name` is provided without `version`, the latest version is used.
 * `checksum` and `archiveFileName` can be used as they both uniquely identify a library.

#### Installing From a URL

If a library you are using is not in the public database just provide its `name` and the `url` fields. The URL can either be a git URL, or a downloadable ZIP file. Arli will use the `url` field if it's available without trying to search for the library elsewhere.

### Generated "lock" file — `Arlifile.<format>`

Whenever `bundle` command succeeds, it will create a "lock" file in the same folder where the `Arlifile` file is located.

The purpose of this file is to list in a machine-parseable way the *fully-resolved* installed library folders. 

There are four lock file formats that are supported, and they can be passed in with the `-f format` eg `--format text` flags to the `bundle` command:

 * `text` 
 * `json`
 * `yaml`
 * `cmake`

Each format produces a file `Arlifile.<format>`: YAML and JSON will simply include the complete library info received from the database, while text format includes a *resolved* library folder names, versions, and the download URL —  all comma separated, one per line.

#### Experimental CMake Integration

The CMake format is currently [**work in progress**](https://github.com/kigster/arli-cmake).

The main goal is to create a CMake "include" file that can automatically build arli-installed libraries, add their locations to the `include_directories` so that the header files can be found. 

> **Help Wanted!** Do you know CMake well? Help us design the CMake and arduino-cmake integration. 

The CMake lock file is meant to be consumed by projects relying on the [arduino-cmake](https://github.com/arduino-cmake/arduino-cmake). We are still working on the complete integration, which would hopefully allow the following features:

 * auto-generate a new Arduino project with the library dependencies using  [arduino-cmake](https://github.com/arduino-cmake/arduino-cmake) as the underlying build tool.

 * Optionally, provide a CMake plugin that runs `arli bundle -f cmake`, and reads the `Arlifile.cmake`. That file will contain CMake code to build each dependent library separately as a static library, and then link it to the firmware in the end.

**CMake Coming Soon!**

#### An Example

Here is the `arli bundle` command inside CMake-based project to build a [Wall Clock using Arduino](https://github.com/kigster/wallclock-arduino). This project has the following `Arlifile`:

```yaml
# vi:syntax=yaml
---
libraries_path: ./libs
lock_format: cmake
dependencies:
- name: "Adafruit GFX Library"
  version: '1.2.0'
- name: "DS1307RTC"
- name: "Adafruit LED Backpack Library"
- name: "Adafruit Unified Sensor"
- name: "DHT sensor library"
- name: "OneButton"
- name: SimpleTimer
  url: https://github.com/jfturcot/SimpleTimer.git
- name: Time
```

You can see that most libraries are specified by name, except one (SimpleTimer) is specified together with the URL, which will be used to `git clone` the library.

So let's specify where our libraries live, and run `arli bundle` inside that project. Below is a screenshot of running `arli` inside of the Wall Clock Arduino project:

Below is the complete help for the `bundle` command for reference:

```
❯ arli bundle -h
Description:
    Installs all libraries specified in Arlifile

        This command reads Arlifile (from the current
        folder, by default), and then it installs all dependent libraries
        specified there, checking if each already exists, and if not —
        downloading them, and installing them into your Arduino Library
        folder. Both the folder with the Arlifile, as well as the destination
        library path folder can be changed with the command line flags.

Usage:
    arli bundle [options]

Options
    -l, --lib-path PATH    Destination: typically your Arduino libraries folder
                           Defaults to ~/Documents/Arduino/Libraries

    -a, --arli-path PATH   An alternate folder with the Arlifile file.
                           Defaults to the current directory.

    -f, --format FMT       Arli writes an Arlifile.lock with resolved info.
                           The default format is text. Use -f to set it
                           to one of: cmake, text, json, yaml

    -e, --if-exists ACTION If a library folder already exists, by default
                           it will be overwritten or updated if possible.
                           Alternatively you can either abort or backup

    -C, --no-color         Disable any color output.
    -D, --debug            Print debugging info.
    -t, --trace            Print exception stack traces.
    -v, --verbose          Print more information.
    -q, --quiet            Print less information.
    -V, --version          Print current version and exit
    -h, --help             prints this help

arli (0.9.0) © 2017 Konstantin Gredeskoul, MIT License.
```

<a name="command-install"></a>

### Command `install`

Use this command to install a single library by either a name or URL:

Eg:

```bash
❯ arli install 'Adafruit GFX Library' -l ./libs
❯ arli install 'https://github.com/jfturcot/SimpleTimer'
```

Complete help is:

```bash
❯ arli install -h
Description:
    Installs a single library either by searching, or url or local ZIP

        This command installs a single library into your library path (which
        can be set with --lib-path flag). Arli interpretes the
        third argument to arli install as either an exact
        library name, or a remote URL (either ZIP or Git Repo). You can use
        search command to first find the right library
        name, and then pass it to the install command.

Usage:
    arli install [ "Exact Library Name" | url ]  [options]

Options
    -l, --lib-path PATH    Destination: typically your Arduino libraries folder
                           Defaults to ~/Documents/Arduino/Libraries

    -e, --if-exists ACTION If a library folder already exists, by default
                           it will be overwritten or updated if possible.
                           Alternatively you can either abort or backup

    -C, --no-color         Disable any color output.
    -D, --debug            Print debugging info.
    -t, --trace            Print exception stack traces.
    -v, --verbose          Print more information.
    -q, --quiet            Print less information.
    -V, --version          Print current version and exit
    -h, --help             prints this help

Examples:
    # Install the latest version of this library locally
    arli install "Adafruit GFX Library" -l ./libraries

    # Install the library from a Github URL
    arli install https://github.com/jfturcot/SimpleTimer```

<a name="command-search"></a>

### Command `search`

To search Arduino library database, you can use the search command.

You can search in two ways:

 1. simple substrin match of the library name
 2. complex arbitrary attribute match, that supports regular expressions and more.

`arli search AudioZero` does a simple search by name, and would match any library with 'AudioZero' in the name, such as `AudioZeroUpdated`. This search returns three results sorted by the version number:

```
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

```
❯ arli search 'name: /adafruit/i'

--------------------------------------------------------------------------------
Arli (0.8.4), Command: search
Library Path: ~/Documents/Arduino/Libraries
--------------------------------------------------------------------------------

Adafruit ADS1X15                                (1.0.0)    ( 1 total versions )
Adafruit ADXL345                                (1.0.0)    ( 1 total versions )
Adafruit AHRS                                   (1.1.3)    ( 5 total versions )
Adafruit AM2315                                 (1.0.1)    ( 2 total versions )
Adafruit AMG88xx Library                        (1.0.0)    ( 1 total versions )
......
dafruit WS2801 Library                         (1.0.0)    ( 1 total versions )
Adafruit microbit Library                       (1.0.0)    ( 1 total versions )
Adafruit nRF8001                                (1.1.1)    ( 2 total versions )
Adafruit seesaw Library                         (1.0.1)    ( 2 total versions )
Adafruit_VL53L0X                                (1.0.2)    ( 2 total versions )
Adafruit_VL6180X                                (1.0.2)    ( 2 total versions )
Adafruit_mp3                                    (1.0.1)    ( 2 total versions )
WEMOS Matrix Compatible With Adafruit GFX       (1.2.0)    ( 3 total versions )
———————————————————————
  Total Versions : 355
Unique Libraries : 116
———————————————————————
```

Finally, you can change the output format of the search, by passing `-f <format>`, where `format` can be `short` (the default), `long`, `json`, or `yaml`.

For example, here is a how long format looks like:

```
❯ arli search 'name: /adafruit/i'  -f long

--------------------------------------------------------------------------------
Arli (0.8.4), Command: search
Library Path: ~/Documents/Arduino/Libraries
--------------------------------------------------------------------------------
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
_______________________________________________________________
Name:        Adafruit AHRS
Versions:    1.1.3, 1.1.2, 1.1.0, 1.0.2, 1.0.0
Author(s):   Adafruit
Website:     https://github.com/adafruit/Adafruit_AHRS
Sentence:    AHRS (Altitude and Heading Reference System) for Adafruit's 
             9DOF and 10DOF breakouts
_______________________________________________________________
```


With `-m LIMIT` flag you can limit number of results. But in our cas above we printed all libraries that had the word "adafruit" (case insensitively) in their official name. We could have used `version:`, or `author`, or `website`, or even `url` and `archiveFileName` fields. For complete description of available library attributes, please see the official definition of the [`library.properties`](https://github.com/arduino/Arduino/wiki/Arduino-IDE-1.5:-Library-specification#library-metadata) file.

A detailed description of the complete search functionality is documented in the library that provides it — [arduino-library](https://github.com/kigster/arduino-library#using-search). Arli uses `arduino-library` gem behind the scenes to search, and lookup libraries.

Below is the help screen for the search command:

```
❯ arli search -h
Description:
    Search standard Arduino Library Database with over 4K entries

        This command provides both the simple name-based search interface, and
        the most sophisticated attribute-specific search using a downloaded,
        and locally cached Public Arduino Database JSON file, maintained by
        the Arduino Community. If you know of another database, that's what
        the --database flag is for. Note that you can print the
        list of available attributes by running arli with
        --print-attrs flag.

Usage:
    arli search [ -A | search-expression ]  [options]

Options
    -d, --database URL     a JSON(.gz) file path or a URL of the library database.
                           Defaults to the Arduino-maintained database.

    -m, --max NUMBER       if provided, limits the result set using the
                           total number of the unique library name matches.
                           Default is 0, which means no limit.

    -f, --format FMT       Optional format of the search results.
                           The default is short. Available
                           formats: with_versions, long, short, json, yaml

    -A, --print-attrs      prints full list of available library
                           attributes that can be used in search strings.

    -C, --no-color         Disable any color output.
    -D, --debug            Print debugging info.
    -t, --trace            Print exception stack traces.
    -v, --verbose          Print more information.
    -q, --quiet            Print less information.
    -V, --version          Print current version and exit
    -h, --help             prints this help

Examples:
    # Finds any library with name matching a given string, case insensitively
    arli search audiozero

    # If the first character is "/", then the argument is assumed to be regex
    arli search /AudioZero$/

    # If the first character is "=", then the rest is assumed to be exact name
    arli search =Time

    # Lets get a particular version of the library using another attribute
    arli search 'name: "AudioZero", version: "1.0.2"'

    # Search using case insensitive search for the author
    arli search 'author: /adafruit/i'

    # Finally, search for regex match for "WiFi" in a sentence or a paragraph
    arli search 'sentence: /wifi/i, paragraph: /wifi/i'
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kigster/arli.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
