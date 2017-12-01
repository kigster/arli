require 'arduino/library'

require 'arli/version'
require 'arli/extensions'
require 'arli/errors'
require 'arli/configuration'
require 'arli/library'
require 'arli/commands'

module Arli
  @config = ::Arli::Configuration.config

  class << self
    attr_accessor :config

    def configure(&_block)
      yield(self.config)
    end

    def debug?
      self.config.debug
    end

    def library_path
      self.config.libraries.path
    end

    def default_library_path
      tilda_path(self.config.libraries.path)
    end

    def tilda_path(absolute_path)
      absolute_path.gsub(%r(#{ENV['HOME']}), '~')
    end
  end
end

require 'arli/arli_file'
require 'arli/actions'
require 'arli/cli'
