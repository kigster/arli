require 'logger'

require 'arli/version'
require 'arli/config'
require 'arli/errors'
require 'arli/logger'

module Arli
  @logger = ::Logger.new(STDOUT, level: :info)
  @config = ::Arli::Config

  class << self
    attr_accessor :logger
    attr_reader :config

    include Arli::Logger

    def configure(&_block)
      config.configure(&_block)
    end

    def debug?
      ENV['ARLI_DEBUG'] || false
    end
  end
end

Arli.configure

require 'arli/arli_file'
require 'arli/cli'
