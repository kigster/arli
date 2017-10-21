[![Build Status](https://travis-ci.org/kigster/arli.svg?branch=master)](https://travis-ci.org/kigster/arli)

# Arli

Arli is a simple and easy to use installer of dependencies that can be 
declared in a JSON file of the following format:


```json
{
  "dependencies": [
    {
      "name": "DS1307RTC",
      "git": "https://github.com/PaulStoffregen/DS1307RTC.git"
    },
    {
      "name": "Adafruit_LEDBackpack",
      "git": "https://github.com/adafruit/Adafruit-LED-Backpack-Library.git"
    },
  ]
}
```

Basically a simple pairing of a library/project name (which also happens to be the local 
directory it's cloned into) and a remote URL.

The gem was created to fill the need of managing many external libraries for an Arduino projects 
in a consistent way. Arli's API was loosely inspired by Bundler.

## Installation

Install the gem globally like this: 

```bash
# if using rbenv, or rvm
$ gem install arli 

# OR, if your Ruby is a system ruby installed in eg. /usr/local, 
$ sudo gem install arli 
```

## Usage

Run `arli --help` for more information:

```
Usage:
    arli [options] [command [options]]

    -L, --lib-home HOME              Specify a local directory where libraries are installed
    -h, --help                       prints this help

  Available Commands:
    install      : installs libraries defined in the JSON file
    update       : updates libraries defined in the JSON file
    library      : Install, update, or remove a single library

See arli <command> --help for more information on a specific command.
```

#### Install Command

`install` is currently the only implemented command, and it should be used as follows:

```
Description:
    installs libraries defined in the JSON file

Usage:
    arli install [options]

Command Options
    -L, --lib-home HOME              Specify a local directory where libraries are installed
    -a, --arli-json FILE             JSON file with dependencies (defaults to arli.json)
    -h, --help                       prints this help
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kigster/arli.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
