[![Gem Version](https://badge.fury.io/rb/arli.svg)](https://badge.fury.io/rb/arli)
[![Build Status](https://travis-ci.org/kigster/arli.svg?branch=master)](https://travis-ci.org/kigster/arli)
[![Maintainability](https://api.codeclimate.com/v1/badges/0812671b4bec27ba89b9/maintainability)](https://codeclimate.com/github/kigster/arli/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/0812671b4bec27ba89b9/test_coverage)](https://codeclimate.com/github/kigster/arli/test_coverage)

# Arli

Arli is a simple and easy to use Arduino Dependency Manager, that uses a
a YAML formatted file declaring dependencies, as follows:

```yaml
# vi:syntax=yaml
version: 1.0.0
dependencies:
  - name: Time
  - name: "Adafruit GFX Library"
  - name: SimpleTimer
    url: https://github.com/jfturcot/SimpleTimer
```

The libraries may be specified with a name and url only (in which case the URL will be used to install it), OR a library can be specified by name (and optionally version). In this case, it will be searched among the standard library index provided by the [Arduino official library database](http://downloads.arduino.cc/libraries/library_index.json.gz) JSON file.

The gem was created to fill the need of slightly more complex Arduino projects that DO NOT use Arduino IDE, and instead use other technologies, such as `ArduinoCmake`  in managing many Arduino libraries  in a consistent way. Arli's API was loosely inspired by Bundler.

## Installation

Install the `arli` ruby gem as follows:

```bash
# if using rbenv, or rvm; otherwise you may need to prefix 
# with 'sudo'
$ gem install arli 
```

## Usage

Run `arli --help` for more information:

```bash
age:
    arli [ options ] [ command [ options ]  ]

    -D, --debug            Print debugging info.
    -t, --trace            Print exception stack traces.
    -v, --verbose          Print more information.
    -V, --version          Print current version and exit
    -h, --help             prints this help

Available Commands:
    install      — installs libraries defined in Arlifile
    search       — Flexible Search of the Arduino Library Database

See arli command --help for more information on a specific command.
```

#### Install Command

Use this command to install or re-install libraries.

You can specify libraries in the `Arlifile` by providing either just the `name:` (and posibly `version`) — the name must match exactly a library in the Arduino standard database. Alternatively, your can pass `archiveFileName`, `checksum` — which all uniquely identify a library in the database.

Sometimes a library will not be in the database, in which case just provide the name and `url` field for it. The URL can either be a git URL, or a downloadable ZIP file.


##### Automatic Folder Name Correction

Arli has an build-in action that's invoked during installation of the libraries: once the library is upacked into a folder (either using git or unzip), it's contents is searched for source files. The name of the directory is then compared to the files found, and in some cases Arli will rename the library folder to match the source files.

For example, 'Adafruit GFX Library' is the proper name of the corresponding library, and it's ZIP archive will unpack into `Adafruit_GFX_Library-1.4.3` folder.  Arli will first remove the version number, and move it to `Adafruit_GFX_Library`, but then it will detect that the file inside is `Adafruit_GFX.h`, and so the top-level folder gets renamed to `Adafruit_GFX` as well. This is an audacious attempt to make sense of the chaos that is the Arduino Library world.

##### An Example

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

```bash
❯ export ARDUINO_CUSTOM_LIBRARY_PATH=~/Documents/Arduino/libraries/
❯ cd skethes/wallclock-arduino
❯ arli install
Adafruit GFX Library (1.2.2) ....... (Adafruit_GFX)
DS1307RTC (1.4.0) ......
Adafruit LED Backpack Library (1.1.6) ....... (Adafruit_LEDBackpack)
Adafruit Unified Sensor (1.0.2) ....... (Adafruit_Sensor)
DHT sensor library (1.3.0) ....... (DHT)
OneButton (1.2.0) .......
SimpleTimer running git clone -v https://github.com/jfturcot/SimpleTimer.git ~/Documents/Arduino/libraries/SimpleTimer 2>&1 .
s (1.5.0) ......
```

Now, we can inspect the library folder and observe that all of the specified libraries have been installed, and into correct folders:

```bash
❯ ls -1 ~/Documents/Arduino/libraries
Adafruit_GFX
DS1307RTC
Adafruit_LEDBackpack
Adafruit_Sensor 
DHT
OneButton
SimpleTimer
Time
```

Below is the complete help for the install command:


```bash
Description:
    installs libraries defined in Arlifile

Usage:
    arli install [options]

Command Options
    -l, --libraries PATH   Local folder where libraries are installed
                           Defaults to ~/Dropbox/Workspace/oss/arduino/libraries

    -a, --arli-path PATH   Folder where Arlifile is located,
                           Defaults to the current directory.

    -e, --if-exists ACTION If a library folder already exists, by default
                           it will be overwritten or updated if possible.
                           Alternatively you can either abort or backup

    -D, --debug            Print debugging info.
    -t, --trace            Print exception stack traces.
    -v, --verbose          Print more information.
    -V, --version          Print current version and exit
    -h, --help             prints this help
```

#### Search Command

To search Arduino library database, you can use the search command.

You can search in two ways:

 1. simple name match
 2. complex arbitrary attribute match, that supports regular expressions and more.

`arli search AudioZero` does a simple search by name, and returns 3 results:

```bash
❯ arli search AudioZero
AudioZero (1.0.1), by Arduino
AudioZero (1.0.0), by Arduino
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
