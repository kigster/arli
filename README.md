[![Gem Version](https://badge.fury.io/rb/arli.svg)](https://badge.fury.io/rb/arli)
[![Build Status](https://travis-ci.org/kigster/arli.svg?branch=master)](https://travis-ci.org/kigster/arli)
[![Maintainability](https://api.codeclimate.com/v1/badges/0812671b4bec27ba89b9/maintainability)](https://codeclimate.com/github/kigster/arli/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/0812671b4bec27ba89b9/test_coverage)](https://codeclimate.com/github/kigster/arli/test_coverage)

Please visit Gitter to discuss this project.

[![Gitter](https://img.shields.io/gitter/room/gitterHQ/gitter.svg)](https://gitter.im/arduino-cmake-arli/) 


# Arli — The Missing Arduino Library Manager

**Arli** is a simple and very easy to use command-line tool, that provides several key functions to aid in Arduino project development. 

### Why not Arduino IDE? Why not Platform.IO?

Arduino IDE is not meant for professional engineers — it's an educational tool for students. But if you want to build a sophisticated project in Arduino, you could leverage most of the Object Oriented practices thanks to the C++ support, as well as decoupling your code into modules and/or libraries.

Unfortunately, this is not very easy to do with neither Arduino IDE, nor Platform.IO AFAIK.

### So, How does Arli Do It?

Arli integrates natively with the [arduino-cmake](https://github.com/arduino-cmake/arduino-cmake) project, and provides an automatic generator for new projects, that should compile and upload out of the box.

You can easily declare new library depenencies, and Arli will happily find and install them for you, while the [arli-cmake](https://github.com/kigster/arli-cmake) project (that's a bridge between the two) knows how to compile each external library into a static .a object, and link it with your firmware in the end.

## Overview

Arli offers several commands, explained below:

 * `arli search [ terms ]` — search for a library by name or any attribute

 * `arli install 'library-name'` — search, and install a single library
 * `arli bundle` — uses a YAML-formatted `Arlifile` to install a bunch of dependencies. Can optionally generate a CMake include file for this project.
 * `arli generate ProjectName --workspace ~/coding` — generates a clean brand new project in a given folder, that's equipped with `Arlifile`, and builds out of the box.

### Arlifile and Bundle Command

`Arlifile` should be placed at the top of your project sources. Here is an example of a simple Arlifile with a bunch of dependencies:

![](docs/arlifile.png)

Next, below is a screenshot of running `arli bundle` inside of that folder. In this particular case, libraries are installed into the default folder `~/Documents/Arduino/Libraries`:

![](docs/arli-in-action.png)

#### Bundle Command Explained

Let's break down what you see on the above screenshot: 

 * First Arli prints the header, containing Arli version, the command, as well as the destination library path that the libraries are going to get installed to.

 * Next, Arli is looping, and for each library without the `url` field, it performs a search by the library `name` (and optionally its `version`), and then it prints the resulting library's name in blue. 
 * The `version` that either was specified in the `Arlifile`, or is the latest for this library is printed next, in green. 
 * Then Arli downloads the library sources either using the URL provided, or the URL attribute of the search result. Note, that **Arli always downloads libraries into a temporary folder first.**. 
 * Arli then scans the files inside each folder, and cleverly determines the *canonical directory name* for each library based on the most appropriate C/C++ header file. 
 * Next, the library is moved to the new canonical name  within the temporary folder, and then the canonical folder is moved into the destination library path. 
 * If the destination folder already exist, there are three possible actions that can be specified via `-e` flag that will happen:

    * the silent default action is to simply **overwrite the existing library folder**.
    * by using `-e [ abort | backup ]` you can optionally either abort the installation, or create a backup of each existing folder.

#### Arlifile "Lock" File

Whenever `bundle` command runs using an `Arlifile`, upon completion another file will be found in the same folder: typically `Arlifile.txt`, which contains metadata about libraries installed.

What's powerful is you can change the format of this file:

```
$ arli bundle -f [ yaml | json | cmake ]
```

Will create `Arlifile.yaml` or `Arlifile.cmake` with the set of resolved libraries.



<a name="folder-detection"></a>

#### Automatic Folder Name Correction

Arli understands that the folder where the library is installed must be named correctly: in other words, **folder name must match the header file inside of the folder** for the library to be found.

When Arli downloads libraries in ZIP format, they are unpacked into folder that are named differently. Arli will then search that folder for the source and header files. The name of the directory is then compared to the files found, and in some cases Arli will automatically **rename the library folder to match the main header file.**. 

> For example, 'Adafruit GFX Library' is the proper name of a corresponding library, and it's ZIP archive will unpack into a folder named `Adafruit_GFX_Library-1.4.3`.  Arli will then detect that the header file inside the folder is `Adafruit_GFX.h`. In this case Arli will rename the top-level folder to `Adafruit_GFX`, and make the library valid, and its folder easily found. 

<a name="command-generate"></a>

## Command Generate

This command creates a new project using the template provided by the [`arli-cmake`](https://github.com/kigster/arli-cmake) project.

```bash
$ arli generate MyClock --workspace ~/arduino/sketches
```

This command will create a brand new project under `~/arduino/sketches/MyClock`, and you should be able to build it right away:

```bash
cd ~/arduino/sketches/MyClock
bin/setup 
cd src
rm -rf build && mkdir build && cd build
cmake ..
make
make upload
```

The above steps can also be done via `bin/build src` bash script.

There is an additional `example` folder that shows the complete example that uses external libraries, and builds and compiles using CMake and Arli.

> **IMPORTANT**: Please do not forget to run `bin/setup` script. It downloads `arduino-cmake` dependency, without which the project will not build.


<a name="command-bundle"></a>

## Command Bundle

Use this command to install Arduino libraries defined in the `Arlifile` yaml file.

Below is a pretty comprehensive version, which not only defines external dependencies to be installed (in the `:depenencies` key), but also specifies built-in Arduino libraries, including Hardware libraries such as `Wire`. 

Arlifile can also specify it's own installation path, lock file format (see below), and some additional device parameters.

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

#### Generated "lock" file — `Arlifile.<format>`

Whenever `bundle` command succeeds, it will create a "lock" file in the same folder where the `Arlifile` file is located.

The purpose of this file is to list in a machine-parseable way the *fully-resolved* installed library folders. 

There are four lock file formats that are supported, and they can be passed in with the `-f format` eg `--format text` flags to the `bundle` command:

 * `text` 
 * `json`
 * `yaml`
 * `cmake`

Each format produces a file `Arlifile.<format>`: YAML and JSON will simply include the complete library info received from the database, while text format includes a *resolved* library folder names, versions, and the download URL —  all comma separated, one per line.

#### CMake Integration

The CMake format is now fully supported, in tandem with `arduino-cmake` project.

See the `generate` command, which creates a new project with CMake enabled.


<a name="command-install"></a>

## Command `install`

Use this command to install a single library by either a name or URL:

Eg:

```bash
❯ arli install 'Adafruit GFX Library' -l ./libs
❯ arli install 'https://github.com/jfturcot/SimpleTimer'
```

<a name="command-search"></a>

## Command `search`

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
Adafruit WS2801 Library                         (1.0.0)    ( 1 total versions )
Adafruit microbit Library                       (1.0.0)    ( 1 total versions )
Adafruit nRF8001                                (1.1.1)    ( 2 total versions )
———————————————————————
  Total Versions : 355
Unique Libraries : 116
———————————————————————
```

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

## Discussion

### More Reasons Why Arli is Needed

Arli is both an *Arduino Library Manager* and a project generator. If you are using Arduino IDE you may be wondering **why is this needed?**

 * Well, for one, Arli can "bundle" libraries not just from the official Arduino database, but also from individual Github URLs. There are thousands of libraries of high quality, that for one reason or another did not make it into the official database.

 * Arduino still haven't come up with a way to automatically document project's dependencies on a set of libraries. I believe the best you've got is having to list libraries in comments, and then install each manually. With Arli you can automate this entire process.
 * [Not everyone likes using Arduino IDE](https://kig.re/2014/08/02/arduino-ide-alternatives.html). So this tool is, perhaps, aimed more at the professional programmers, wanting to build applications that tend to be on a complex side, and rely on multiple third party libraries. Boards like Teensy have a lot more RAM than Arduino UNO and clones, and so it can support much larger projects with dozens of libraries linked in with the firmware.
 * One of Arli's design goals is to provide a bridge between the [arduino-cmake](https://github.com/arduino-cmake/arduino-cmake) project, which provides an alternative build system, and is compatible with numerous IDEs such as [Atom](https://atom.io), [JetBrains CLion](https://www.jetbrains.com/clion/), [Visual Studio Code](https://code.visualstudio.com/), or even [Eclipse](https://eclipse.org).



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kigster/arli.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
