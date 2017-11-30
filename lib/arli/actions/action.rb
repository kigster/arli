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
          action_name                          = klazz.name.gsub(/.*::/, '').underscore.to_sym
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

      def overwrite?
        config.if_exists.overwrite
      end

      def backup?
        config.if_exists.backup
      end

      def abort?
        config.if_exists.abort
      end

      def mv(from, to)
        handle_preexisting_folder(to)
        FileUtils.mv(from, to)
      end

      def handle_preexisting_folder(to)
        if Dir.exist?(to)
          if abort?
            raise ::Arli::Errors::LibraryAlreadyExists, "Directory #{to} already exists"
          elsif backup?
            backup!(to)
          elsif overwrite?
            FileUtils.rm_rf(to)
          end
        end
      end

      def backup!(p)
        if Dir.exist?(p)
          backup_path = "#{p}.arli-backup-#{Time.now.strftime('%Y%m%d%H%M%S')}"
          FileUtils.mv(p, backup_path)
          if config.verbose
            ___ "\nNOTE: path #{p.blue} has been backed up to #{backup_path.bold.green}\n"
          elsif !config.quiet
            ___ ' backed up and'
          end
        end
      end
    end
  end
end
