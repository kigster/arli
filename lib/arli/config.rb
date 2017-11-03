require 'dry-configurable'
require 'arduino/library'

module Arli
  class Config
    extend Dry::Configurable

    DEFAULT_FILENAMES = %w(Arlifile Arlifile Arlifile.yml Arlifile.yaml
               arlifile arlifile.yml arlifile.yaml
               ArliFile ArliFile ArliFile.yml ArliFile.yaml).freeze

    setting :arlifile, reader: true do
      setting :candidates, DEFAULT_FILENAMES, reader: true
      setting :name, DEFAULT_FILENAMES.first, reader: true
    end

    setting :library, reader: true do
      setting :path, ::Arduino::Library::DefaultDatabase.library_path, reader: true
      setting :index_url, ::Arduino::Library::DefaultDatabase.library_index_url, reader: true
      setting :index_path, ::Arduino::Library::DefaultDatabase.library_index_path, reader: true
    end
  end
end
