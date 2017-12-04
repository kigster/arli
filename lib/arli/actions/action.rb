require_relative '../output'

module Arli
  module Actions
    # Represents an abstract action related to the library
    class Action
      include Arli::Output

      extend Forwardable
      def_delegators :@library,
                     :exists?,
                     :path, :temp_path,
                     :dir, :temp_dir,
                     :libraries_home

      class << self
        def inherited(base)

          base.instance_eval do
            class << self
              attr_writer :check_command, :check_pattern, :description

              def action_name
                name.gsub(/.*::/, '').underscore.to_sym
              end

              def set_or_get(var_name, val = nil)
                var = "@#{var_name}".to_sym
                self.instance_variable_set(var, val) if val
                self.instance_variable_get(var)
              end

              def check_pattern(val = nil)
                set_or_get('check_pattern', val)
              end

              def check_command(val = nil)
                set_or_get('check_command', val)
              end

              def description(val = nil)
                set_or_get('description', val)
              end
            end
          end

          # Add to the list of actions
          ::Arli::Actions.actions[base.action_name] = base
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
