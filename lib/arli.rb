require 'arli/version'
require 'arli/cli'
require 'logger'

module Arli
  DEFAULT_JSON_FILE_ENV = 'ARDUINO_ARLI_LIBRARY_FILE'.freeze
  DEFAULT_JSON_FILE     = ENV[DEFAULT_JSON_FILE_ENV] || 'arli.json'.freeze

  DEFAULT_LIBRARY_PATH_ENV = 'ARDUINO_CUSTOM_LIBRARY_PATH'.freeze
  DEFAULT_LIBRARY_PATH     = ENV[DEFAULT_LIBRARY_PATH_ENV] || (ENV['HOME'] + '/Documents/Arduino/Libraries')

  DEBUG = ENV['DEBUG'] ? true : false

  @logger       = Logger.new(STDOUT)
  @logger.level = Logger::INFO

  class << self
    attr_accessor :logger

    %i(debug info error warn fatal).each do |level|
      define_method level do |*args|
        self.logger.send(level, *args) if self.logger
      end
    end
  end
end

