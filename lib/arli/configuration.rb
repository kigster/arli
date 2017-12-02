require 'dry-configurable'
require 'arduino/library'
require 'yaml'

module Arli
  class Configuration

    DEFAULT_FILENAME      = 'Arlifile'.freeze
    ACTIONS_WHEN_EXISTS   = %i(backup overwrite abort)
    ARLI_COMMAND          = 'arli'.freeze
    DEFAULT_RESULTS_LIMIT = 100

    extend Dry::Configurable

    # These are populated during the parsing of the params
    setting :runtime do
      setting :argv
      setting :command do
        setting :name
        setting :instance
      end
    end

    # Default locations
    setting :libraries do
      setting :path, ::Arduino::Library::DefaultDatabase.library_path
    end

    setting :database do
      setting :path, ::Arduino::Library::DefaultDatabase.library_index_path
      setting :url, ::Arduino::Library::DefaultDatabase.library_index_url
    end

    setting :if_exists do
      setting :overwrite, true
      setting :backup, false
      setting :abort, false
    end

    # Global flags
    setting :debug, ENV['ARLI_DEBUG'] || false
    setting :trace, false
    setting :verbose, false
    setting :help, false
    setting :quiet, false

    # Commands
    setting :search do
      setting :argument
      setting :default_field, :name
      setting :results do
        setting :attrs
        setting :limit, DEFAULT_RESULTS_LIMIT
        setting :format, :inspect
      end
    end

    setting :bundle do
      setting :library_names, []
      # Arlifile
      setting :arlifile do
        setting :path, ::Dir.pwd
        setting :name, ::Arli::Configuration::DEFAULT_FILENAME
      end
    end

    setting :install do
      setting :name
      setting :url
    end

  end
end


