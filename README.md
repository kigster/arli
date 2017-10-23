[![Build Status](https://travis-ci.org/kigster/arli.svg?branch=master)](https://travis-ci.org/kigster/arli)

# Arli

Arli is a simple and easy to use installer of dependencies that can be 
declared in a YAML file named `ArliFile.yml`, which might look something like this:

```yaml
version: 1.0.0
dependencies:
  - name: ESP8266WiFi
    version: '1.0'
    url: https://github.com/esp8266/Arduino
    subfolder: libraries/ESP8266WiFi
  - name: NTPClient
    version: '3.1.0'
  - name: SimpleTimer
    urL: https://github.com/jfturcot/SimpleTimer
```

Libraries with `url` field provided, will use that URL. If no url field is provided, the Arduino Library index is searched for the name and version, and if found uses that. (NOTE: current version still requires URL field, but the index lookup will be implemented shortly).

The gem was created to fill the need of slightly more complex Arduino projects that DO NOT use Arduino IDE, and instead use other technologies, such as `ArduinoCmake`  in managing many Arduino libraries  in a consistent way. Arli's API was loosely inspired by Bundler.

## Installation

Install the `arli` ruby gem as follows:

```bash
# if using rbenv, or rvm
$ gem install arli 

# OR, if your Ruby is a system ruby installed in eg. /usr/local, 
$ sudo gem install arli 
```

## Usage

Run `arli --help` for more information:

```bash
Usage:
    arli [options] [ command [options] ]

    -h, --help     prints this help

Available Commands:
    install      : installs libraries defined in ArliFile.yml
    update       : updates libraries defined in the ArliFile.yml
    search       : Flexible Search of the Arduino Library Database

See arli <command> --help for more information on a specific command.
```

#### Install Command

Use this command to install libraries for the first time. 

NOTE: unless you pass `-e` flag, install command falls back to `update` if
the target folder already exists.  With `-e` flag, installer aborts if the 
target library already exists.

```bash
Description:
    installs libraries defined in ArliFile.yml

Usage:
    arli install [options]

Command Options
    -l, --lib-home HOME    Local folder where libraries are installed
                           Default: ~/Documents/Arduino/Libraries

    -a, --arli-file FILE   ArliFile.yml is the file listing the dependencies
                           Default filename is ArliFile.yml

    -e, --abort-on-exiting Abort if a library folder already exists
                           instead of updating it.
    -h, --help             prints this help
```

#### Update Command

To upate previously checked out libraries, use the `update` command:

```bash
Description:
    updates libraries defined in the ArliFile

Usage:
    arli update [options]

Command Options
    -l, --lib-home HOME    Local folder where libraries are installed.
                           Default: ~/Documents/Arduino/Libraries

    -a, --arli-file FILE   ArliFile.yml is the file listing the dependencies.
                           Default filename is ArliFile.yml

    -h, --help             prints this help
```

#### Search Command

To search Arduino library database, you can use the search command:

```bash
Description:
    Flexible Search of the Arduino Library Database

Usage:
    arli search [options]

Command Options
    -s, --search TERMS     ruby-style hash arguments to search for
                           eg: -s "name: 'AudioZero', version: /^1.0/"
    -d, --database SOURCE  a JSON file name, or a URL that contains the index
                           By default, the Arduino-maintained list is searched
    -m, --max LIMIT        if provided, limits the result set to this number
                           Default value is 100
    -h, --help             prints this help
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
