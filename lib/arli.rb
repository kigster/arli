require 'arli/version'
require 'arli/cli'

module Arli
  DEFAULT_JSON_FILE_ENV    = 'ARDUINO_ARLI_LIBRARY_FILE'.freeze
  DEFAULT_JSON_FILE        = ENV[DEFAULT_JSON_FILE_ENV] || 'arli.json'.freeze

  DEFAULT_LIBRARY_PATH_ENV = 'ARDUINO_CUSTOM_LIBRARY_PATH'.freeze
  DEFAULT_LIBRARY_PATH     = ENV[DEFAULT_LIBRARY_PATH_ENV] || (ENV['HOME'] + '/Documents/Arduino/Libraries')
end
