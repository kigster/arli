require_relative '../output'

module Arli
  module Actions
    # Represents an abstract action related to the library
    class Action
      include Arli::Output

      extend Forwardable
      def_delegators :@library, :exists?, :path, :dir, :libraries_home

      class << self
        def inherited(klazz)
          action_name = klazz.name.gsub(/.*::/, '').underscore.to_sym
          ::Arli::Actions.actions[action_name] = klazz
        end
      end

      attr_accessor :library, :config

      def initialize(library, config: Arli.config)
        self.library = library
        self.config  = config
      end

      def act(**_opts)
        raise 'Abstract method #act called on Action'
      end

    end
  end
end