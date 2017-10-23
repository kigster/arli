require 'arli/version'
require 'arli/arli_file'
require 'arli/configuration'
require 'arli/cli'
require 'logger'

module Arli
  LIBRARY_INDEX_JSON_GZ = 'http://downloads.arduino.cc/libraries/library_index.json.gz'.freeze

  DEFAULT_ARLI_FILE_ENV = 'ARDUINO_ARLI_LIBRARY_FILE'.freeze
  DEFAULT_ARLI_FILE     = ENV[DEFAULT_ARLI_FILE_ENV] || ArliFile::DEFAULT_FILE_NAME

  DEBUG = ENV['DEBUG'] ? true : false

  @logger       = Logger.new(STDOUT)
  @logger.level = Logger::INFO

  class << self
    attr_accessor :logger
    attr_writer :configuration

    %i(debug info error warn fatal).each do |level|
      define_method level do |*args|
        self.logger.send(level, *args) if self.logger
      end
    end
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end

