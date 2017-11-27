[![Gem Version](https://badge.fury.io/rb/arli.svg)](https://badge.fury.io/rb/arli)
[![Build Status](https://travis-ci.org/kigster/arli.svg?branch=master)](https://travis-ci.org/kigster/arli)
[![Maintainability](https://api.codeclimate.com/v1/badges/0812671b4bec27ba89b9/maintainability)](https://codeclimate.com/github/kigster/arli/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/0812671b4bec27ba89b9/test_coverage)](https://codeclimate.com/github/kigster/arli/test_coverage)

# Arli

Arli is an awesomely simple and very easy to use Arduino Library Installer. It allows your Arduino projects to be portable by includin a tiny file called `Arlifile` that defines your project's external library dependencies. Using either this file, or command line flags, Arli is able to search for libraries, install them locally and do it consistently and reliably.

This way you can share projects with others, and they will be able to automatically download and install the dependent libraries instead of havin to do that manually.

The gem was created to fill the need of slightly more complex Arduino projects that DO NOT use Arduino IDE, and instead use other technologies, such as `ArduinoCmake`  in managing many Arduino libraries  in a consistent way. Arli's API was loosely inspired by Bundler.

## Overview

### How Does It Work?

In a nutshell, Arli relies on the publicly available database of the vast majority of public Ardiuino libraries. This database is maintained by Arduino themselves, and is a [giant gzipped JSON file](http://downloads.arduino.cc/libraries/library_index.json.gz). Arli automatically downloads and caches the index on a local file system, and then lets you search and install libraries using either a simple name search, or more sophisticated ruby-like syntax that supports searching for ANY attribute as an equal match, or a regular expressions, or even a [Proc](http://ruby-doc.org/core-2.4.2/Proc.html).

Sometimes, however, an Arduino library you use may not part of the main database. No problem! Just add the `url:` attribute together with the library name. The URL can either be a Github URL, or a URL to a downloadable ZIP file. Arli will figure out the rest. 

### Arlifile

`Arlifile` is a YAML-formatted file that looks like this below. We list all dependencies using the library names that are provided in the database (you can search for the libraries you need prior to populating this file):


```yaml
# vi:syntax=yaml
# File: Arlifile
version: 1.0.0
dependencies:
  - name: Time
  - name: "Adafruit GFX Library"
    version: '1.2.1'
  - name: SimpleTimer
    url: https://github.com/jfturcot/SimpleTimer
```

The libraries may be specified with a name and url only, in which case no search is performed, and the provided URL is used to install the library.  The library `SimpleTimer` above is not in the main database, therefore we provide URL for Arli to use.

If the URL is not provided, you can specify one of several fields that are searched for a matching library. Remember, in this case Arli must find one and only one library to install, otherwise it will throw an error.

You can provide the following fields in the Arilfile if you want the library to be installed from the central database:

 * `name` should be the exact match. Use double quotes if the name contains spaces.
 * `version` can be used together with the `name` to specify a particular version. Without this field, and if the `name` is provided, the latest version is used.
 * `checksum` and `archiveFileName` can be used as they both uniquely identify a library.

In all of the above cases, Arli will search the standard library database provided by the [Arduino official library database](http://downloads.arduino.cc/libraries/library_index.json.gz) JSON file.

### Single Library Install

You can also install just a single library by passing `--name` flag (`-n`), for example:

```bash
arli install --name 'Adafruit GFX Library'
```

## Gem Installation

Install the `arli` ruby gem as follows:

```bash
# if using rbenv, or rvm; otherwise you may need to prefix 
# with 'sudo'
$ gem install arli 
```

## Usage

Run `arli --help` for more information:

```bash
Usage:
    arli [ options ] [ command [ options ]  ]

    -D, --debug            Print debugging info.
    -t, --trace            Print exception stack traces.
    -v, --verbose          Print more information.
    -q, --quiet            Print less information.
    -V, --version          Print current version and exit
    -h, --help             prints this help

Available Commands:
    install      — installs libraries defined in Arlifile or by -n flag
    search       — Flexible Search of the Arduino Library Database

See arli command --help for more information on a specific command.

arli (0.6.1) © 2017 Konstantin Gredeskoul, MIT License.
```

### Command `install`

Use this command to install or re-install libraries.

You can specify libraries in the `Arlifile` by providing either just the `name:` (and posibly `version`) — the name must match exactly a library in the Arduino standard database. Alternatively, your can pass `archiveFileName`, `checksum` — which all uniquely identify a library in the database.

Sometimes a library will not be in the database, in which case just provide the name and `url` field for it. The URL can either be a git URL, or a downloadable ZIP file.


#### Automatic Folder Name Correction

Arli has an build-in action that's invoked during installation of the libraries: once the library is upacked into a folder (either using git or unzip), it's contents is searched for source files. The name of the directory is then compared to the files found, and in some cases Arli will rename the library folder to match the source files.

For example, 'Adafruit GFX Library' is the proper name of the corresponding library, and it's ZIP archive will unpack into `Adafruit_GFX_Library-1.4.3` folder.  Arli will first remove the version number, and move it to `Adafruit_GFX_Library`, but then it will detect that the file inside is `Adafruit_GFX.h`, and so the top-level folder gets renamed to `Adafruit_GFX` as well. This is an audacious attempt to make sense of the chaos that is the Arduino Library world.

#### An Example

Here is the `arli install` command inside CMake-based project to build a [Wall Clock using Arduino](https://github.com/kigster/wallclock-arduino). This project has the following `Arlifile`:

```yaml
# vi:syntax=yaml
---
dependencies:
- name: "Adafruit GFX Library"
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

So let's specify where our libraries live, and run `arli install` inside that project:


![](arli-in-action.png)

Below is the complete help for the install command for reference:


```bash
Description:
    installs libraries defined in Arlifile or by -n flag

Usage:
    arli install [options]

Command Options
    -n, --name NAME        If provided a library name is searched and, if found
                           installed. In this mode Arlifile not used.

    -l, --libraries PATH   Local folder where custom Arduino libraries are installed
                           Defaults to ~/Dropbox/Workspace/oss/arduino/libraries

    -a, --arli-path PATH   Folder where Arlifile is located,
                           Defaults to the current directory.

    -e, --if-exists ACTION If a library folder already exists, by default
                           it will be overwritten or updated if possible.
                           Alternatively you can either abort or backup

    -D, --debug            Print debugging info.
    -t, --trace            Print exception stack traces.
    -v, --verbose          Print more information.
    -q, --quiet            Print less information.
    -V, --version          Print current version and exit
    -h, --help             prints this help

Examples:
     # Install all libs defined in the ./Arlifile file
     arli install

     # Install a single library matched by the --name flag
     arli install -n "Adafruit GFX Library"```

### Command `search`

To search Arduino library database, you can use the search command.

You can search in two ways:

 1. simple substrin match of the library name
 2. complex arbitrary attribute match, that supports regular expressions and more.

`arli search AudioZero` does a simple search by name, and would match any library with 'AudioZero' in the name, such as `AudioZeroUpdated`. This search returns three results sorted by the version number:

```bash
❯ arli search AudioZero
AudioZero (1.0.0), by Arduino
AudioZero (1.0.1), by Arduino
AudioZero (1.1.1), by Arduino

Total matches: 3
```

The search argument can also be a ruby-syntaxed expression, that (if you know ruby)  is actually `eval`-ed into the method parameters. Here are a few examples:

You can also use regular expressions, and set maximum number of results printed by the `-m MAX` flag.

```bash
❯ arli search 'name: /adafruit/i' -
Adafruit ADS1X15 (1.0.0), by Adafruit
Adafruit ADXL345 (1.0.0), by Adafruit
Adafruit AM2315 (1.0.0), by Adafruit
Adafruit AM2315 (1.0.1), by Adafruit
.....
WEMOS Matrix Compatible With Adafruit GFX Library (1.0.0), by Thomas O Fredericks
WEMOS Matrix Compatible With Adafruit GFX Library (1.1.0), by Thomas O Fredericks
Adafruit SGP30 Sensor (1.0.0), by Adafruit

Total matches: 352
```

With `-m 0` flag, we disabled the default search limit of 100, and got all of the libraries that have the word "adafruit" in their name. We could have used `version:`, or `author`, or `website`, or even `url` and `archiveFileName` fields. For complete description of available library attributes, please see the official definition of the [`library.properties`](https://github.com/arduino/Arduino/wiki/Arduino-IDE-1.5:-Library-specification#library-metadata) file.

A detailed description of the complete search functionality is documented in the library that provides it — [arduino-library](https://github.com/kigster/arduino-library#using-search). Arli uses `arduino-library` gem behind the scenes to search, and lookup libraries.

Below is the help screen for the search command:

```bash
Description:
    Flexible Search of the Arduino Library Database

Usage:
    arli search [ name-match | expression ] [options]

Command Options
    -d FILE/URL,           a JSON file name, or a URL that contains the index
        --database         Defaults to the Arduino-maintained list
    -m, --max NUMBER       if provided, limits the result set to this number
                           Defaults to 100
    -D, --debug            Print debugging info.
    -t, --trace            Print exception stack traces.
    -v, --verbose          Print more information.
    -V, --version          Print current version and exit
    -h, --help             prints this help

Example:
     arli search 'name: /AudioZero/, version: "1.0.1"'
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kigster/arli.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
