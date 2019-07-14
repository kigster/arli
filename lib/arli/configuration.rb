# frozen_string_literal: true

require 'dry-configurable'
require 'arduino/library'
require 'yaml'

module Arli
  class Configuration
    DEFAULT_FILENAME       = 'Arlifile'
    DEFAULT_LOCK_FILENAME  = (DEFAULT_FILENAME + '.lock').freeze
    ACTIONS_WHEN_EXISTS    = %i[backup overwrite abort].freeze
    ARLI_COMMAND           = 'arli'
    DEFAULT_RESULTS_LIMIT  = 0
    GENERATE_TEMPLATE_REPO = 'https://github.com/kigster/arli-cmake'

    extend Dry::Configurable

    # These are populated during the parsing of the params
    setting :runtime do
      setting :argv
      setting :pwd
      setting :command do
        setting :name
        setting :instance
      end
    end

    # Default locations
    setting :libraries do
      setting :path, ::Arduino::Library::DefaultDatabase.library_path
      setting :temp_dir
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
    setting :no_color, false
    setting :dry_run, false
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
        setting :output_format, :short
      end
    end

    setting :generate do
      setting :project_name
      setting :workspace, '.'
      setting :libs
      setting :template_repo, GENERATE_TEMPLATE_REPO
    end

    # Arlifile
    setting :arlifile do
      setting :path, ::Dir.pwd
      setting :name, ::Arli::Configuration::DEFAULT_FILENAME
      setting :lock_name, ::Arli::Configuration::DEFAULT_LOCK_FILENAME
      setting :lock_format, :text
      setting :hash
    end

    setting :bundle do
      setting :library_names, []
    end

    setting :install do
      setting :library
    end
  end
end
