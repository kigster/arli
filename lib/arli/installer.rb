require 'forwardable'
require 'arli'
require_relative 'actions'

module Arli
  class Installer
    include ::Arli::Output

    extend Forwardable
    def_delegators :@library, :exists?

    attr_accessor :library, :config

    def initialize(library, config: Arli.config)
      self.config  = config
      self.library = library
    end

    def install
      ___ "#{library.name.blue} "

      if library.nil? && library.library.nil?
        ___ ' (no library) '
        fuck
      elsif library.url.nil?
        ___ ' (no url) '
        fuck
      else
        ___ "(#{library.version.green}) " if library.version
        actions(library).each do |action|
          run_action(action)
        end
      end
      ___ "\n"
    end

    def run_action(action)
      klass = Arli::Actions.action(action)
      klass.new(library, config: config).act if klass
    end

    def actions(library)
      actions = []
      actions << :backup if exists?
      # First, how do we get the library?
      actions << ((library.url =~ /\.zip$/i) ? :zip_file : :git_repo)
      actions << :dir_name
      actions
    end
  end
end

