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

Use this command to install libraries for the first time. 

NOTE: unless you pass `-e` flag, install command falls back to `update` if
the target folder already exists.  With `-e` flag, installer aborts if the 
target library already exists.

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

To search Arduino library database, you can use the search command:

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

For example:

```bash
$ arli search -s 'name: "AudioZero", version: "1.0.1"'
```

You can also use regular expressions, and set maximum number of results printed by the `-m MAX` flag.

```bash
$ arli search -s 'name: /adafruit/i' -m 10
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kigster/arli.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
