# frozen_string_literal: true

require 'require_dir'

module Arli
  RequireDir.enable_require_dir!(self, __FILE__)
end

require 'arduino/library'
require 'arli/helpers/inherited'
require 'arli/helpers/system_commands'
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
      yield(config)
    end

    def debug?
      config.debug
    end

    def library_path
      config.libraries.path
    end

    def default_library_path
      tilda_path(config.libraries.path)
    end

    def tilda_path(absolute_path)
      absolute_path.gsub(/#{ENV['HOME']}/, '~')
    end
  end
end

require 'arli/arli_file'
require 'arli/actions'
require 'arli/cli'
