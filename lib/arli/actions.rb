# frozen_string_literal: true

module Arli
  module Actions
    class << self
      attr_accessor :actions

      def action(name)
        actions[name]
      end

      def action_name(klass)
        actions.invert[klass]
      end
    end
  end
end

Arli::Actions.actions = {}

require_relative 'actions/action'
require_relative 'actions/unzip_file'
require_relative 'actions/git_repo'
require_relative 'actions/dir_name'
require_relative 'actions/move_to_library_path'
