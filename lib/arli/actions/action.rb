require 'arli/helpers/output'
require 'arli/helpers/inherited'

module Arli
  module Actions
    # Represents an abstract action related to the library
    class Action
      include Arli::Helpers::Output

      include Arli::Helpers::Inherited
      attr_assignable :check_command, :check_pattern, :description

      extend Forwardable
      def_delegators :@library,
                     :exists?,
                     :path, :temp_path,
                     :dir, :temp_dir,
                     :libraries_home

      class << self
        def inherited(base)
          ::Arli::Actions.actions[base.short_name] = base
        end
      end

      attr_accessor :library, :config

      def initialize(library, config: Arli.config)
        self.library = library
        self.config  = config
      end

      def run!
        execute
      rescue Exception => e
        action_fail(self, e)
      end

      def supported?
        return @supported if defined?(@supported)
        if self.class.check_command && self.class.check_pattern
          @supported = (`#{self.class.check_command} 2>/dev/null | grep "#{self.class.check_pattern}"`.chomp != '')
        else
          @supported = true
        end
      end

      def mv(from, to)
        FileUtils.mv(from, to)
      end

      def to_s
        "<Action:#{(Arli::Actions.action_name(self) || 'unknown action').bold.blue}: lib=#{library.name}>"
      end

      protected

      def execute(**_opts)
        raise Arli::Errors::AbstractMethodCalled,
              'Abstract method #execute called on Base'
      end


    end
  end
end
