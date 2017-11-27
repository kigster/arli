module Arli
  module Actions
    class << self
      attr_accessor :actions

      def action(name)
        self.actions[name]
      end
    end
  end
end

Arli::Actions.actions = {}

require_relative 'actions/action'
require_relative 'actions/zip_file'
require_relative 'actions/git_repo'
require_relative 'actions/dir_name'
require_relative 'actions/backup'
