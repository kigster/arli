require 'forwardable'
require 'logger'
require 'arduino/library'

require 'arli/version'
require 'arli/errors'
require 'arli/logger'
require 'arli/config'

module Arli

  class << self
    attr_accessor :config
  end

  self.config = ::Arli::Config

  class << self
    extend Forwardable
    def_delegators :@config, *::Arli::Config::PARAMS

    def configure(&_block)
      yield(self.config)
    end

    def debug?
      self.debug
    end
  end
end

Arli.configure do |config|
  config.library_path       = ::Arduino::Library::DefaultDatabase.library_path
  config.library_index_path = ::Arduino::Library::DefaultDatabase.library_index_path
  config.library_index_url  = ::Arduino::Library::DefaultDatabase.library_index_url
  config.logger             = ::Logger.new(STDOUT, level: :info)
  config.debug              = ENV['ARLI_DEBUG'] || false
end

require 'arli/arli_file'
require 'arli/cli'
