[![Gem Version](https://badge.fury.io/rb/arli.svg)](https://badge.fury.io/rb/arli)
[![Build Status](https://travis-ci.org/kigster/arli.svg?branch=master)](https://travis-ci.org/kigster/arli)
[![Maintainability](https://api.codeclimate.com/v1/badges/0812671b4bec27ba89b9/maintainability)](https://codeclimate.com/github/kigster/arli/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/0812671b4bec27ba89b9/test_coverage)](https://codeclimate.com/github/kigster/arli/test_coverage)

**NOTE: This software is currently in BETA. Bugs are possible, and reporting them is encouraged.**

# Arli

Arli is an awesomely simple and very easy to use Arduino Library Installer. It allows your Arduino projects to be portable by including a small text file called `Arlifile` that defines your project's Arduino library dependencies. Using either this file, or command line flags, Arli is able to search for libraries, install them locally to a custom location, and do it all consistently and reliably.

That way you can share projects with others and they will be able to automatically download and install the dependent libraries instead of having to do that manually. The project is inspired by [Bundler](http://bundler.io/).

Here is a screenshot of running `arli bundle` inside a project with the `Arlifile` that defines all of the project's library dependencies. We install into a default libraries folder `~/Documents/Arduino/Libraries`:

![](docs/arli-in-action.png)

## Overview

### How Does It Work?

In a nutshell, Arli relies on the publicly available database of the vast majority of public Ardiuino libraries. This database is maintained by Arduino themselves, and is a [giant gzipped JSON file](http://downloads.arduino.cc/libraries/library_index.json.gz). Arli automatically downloads and caches the index on a local file system, and then lets you search and install libraries using either a simple name search, or more sophisticated ruby-like syntax that supports searching for ANY attribute as an equal match, or a regular expressions, or even a [Proc](http://ruby-doc.org/core-2.4.2/Proc.html).

Sometimes, however, an Arduino library you use may not part of the main database. No problem! Just add the `url:` attribute together with the library name. The URL can either be a Github URL, or a URL to a downloadable ZIP file. Arli will figure out the rest. 

### Arlifile and `bundle`

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

### Single Library and `install`

You can also install just a single library by using the `install` command, instead of the `bundle`. Install accepts either a `--lib-name` flag (`-n`), or a url `-u`, `--lib-url`, for example:

```bash
arli install --lib-name 'Adafruit GFX Library'
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
    arli options
    arli command [ options ]

    -C, --no-color         Disable any color output.
    -D, --debug            Print debugging info.
    -t, --trace            Print exception stack traces.
    -v, --verbose          Print more information.
    -q, --quiet            Print less information.
    -V, --version          Print current version and exit
    -h, --help             prints this help

Available Commands:
    search       — Search the Arduino Library Database (or a custom one)
    bundle       — installs all libraries defined in the Arlifile
    install      — installs a single library

See arli command --help for more information on a specific command.

arli (0.8.0) © 2017 Konstantin Gredeskoul, MIT License.
```

### Command `bundle`

Use this command to install Arduino libraries.

You can specify libraries in the `Arlifile` by providing just the `name:` (and posibly `version`) — the name must match exactly a library in the Arduino standard database. Alternatively, your can pass fields `archiveFileName`, `checksum` — which all uniquely identify a library in the database.

If a library you are using is not in the public database just provide its `name` and the `url` fields. The URL can either be a git URL, or a downloadable ZIP file. Arli will use the `url` field if it's available without trying to search for the library elsewhere.

#### Automatic Folder Name Correction

Arli understands that the folder where the library is installed must be named correctly: in other words, **folder name must match the header file inside of the folder** for the library to be found.

When Arli downloads libraries in ZIP format, they are unpacked into folder that are named differently. Arli will then search that folder for the source and header files. The name of the directory is then compared to the files found, and in some cases Arli will automatically **rename the library folder to match the main header file.**. 

> For example, 'Adafruit GFX Library' is the proper name of a corresponding library, and it's ZIP archive will unpack into a folder named `Adafruit_GFX_Library-1.4.3`.  Arli will then detect that the header file inside the folder is `Adafruit_GFX.h`. In this case Arli will rename the top-level folder to `Adafruit_GFX`, and make the library valid, and its folder easily found. 
> 
> This is an audacious attempt to make sense of the chaos that is the Arduino Library world.

#### An Example

Here is the `arli bundle` command inside CMake-based project to build a [Wall Clock using Arduino](https://github.com/kigster/wallclock-arduino). This project has the following `Arlifile`:

```yaml
# vi:syntax=yaml
---
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


```bash
❯ be exe/arli bundle -h
Usage:
    arli bundle [options]

Options
    -l, --lib-path PATH    Local folder where custom Arduino libraries are installed
                           Defaults to ~/Dropbox/Workspace/oss/arduino/libraries

    -a, --arli-path PATH   Folder where Arlifile is located,
                           Defaults to the current directory.

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

Description:
    installs all libraries defined in the Arlifile

Examples:
     # Install all libs defined in Arlifile:
     arli bundle

     # Install all libs defined in src/Arlifile
     arli bundle -a src
```

### Command `install`

Use this command to install a single library by either a name or URL:

Eg:

```bash
❯ be exe/arli install -n 'Adafruit GFX Library' -l ./libs
❯ be exe/arli install -u 'https://github.com/jfturcot/SimpleTimer' -l ./libs
```

Complete help is:


```bash
❯ be exe/arli install -h
Usage:
    arli install [ "name" | [ git-url | zip-url ] [options]

Options
    -l, --lib-path PATH    Local folder where custom Arduino libraries are installed
                           Defaults to ~/Dropbox/Workspace/oss/arduino/libraries

    -u, --lib-url URL      Attempts to install the library by its URL
                           Github project URL or a downloadable Zip are supported.
    -n, --lib-name NAME    Searches and installs library by its name,
                           unless URL is also provided
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

Description:
    installs a single library

Examples:
     # Install the latest version of this library
     arli install -n "Adafruit GFX Library"

     # Install the library from a Github URL
     arli install -u https://github.com/jfturcot/SimpleTimer
```

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
❯ arli search 'name: /adafruit/i' -m 0
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
❯ be exe/arli search -h
Usage:
    arli search [ name | search-expression ] [options]

Options
    -d, --database URL     a JSON(.gz) file path or a URL of the library database.
                           Defaults to the Arduino-maintained database.
    -m, --max NUMBER       if provided, limits the result set to this number
                           Set to 0 to disable. Default is 100.
    -C, --no-color         Disable any color output.
    -D, --debug            Print debugging info.
    -t, --trace            Print exception stack traces.
    -v, --verbose          Print more information.
    -q, --quiet            Print less information.
    -V, --version          Print current version and exit
    -h, --help             prints this help

Description:
    Search the Arduino Library Database (or a custom one)

Examples:
     # Search using the regular expression containing the name:
     arli search AudioZero

     # Same exact search as above, but using ruby hash syntax:
     arli search 'name: /AudioZero/'

     # Search using case insensitive name search, and :
     arli search 'name: /adafruit/i'

     # Finally, search for the exact name match:
     arli search '^Time$'
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kigster/arli.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
