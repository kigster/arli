require_relative 'output'

module Arli
  module Helpers
    module SystemCommands
      include Output

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
          print_target_dir(backup_path, 'backed up')
          if verbose?
            ___ "\nNOTE: path #{p.blue} has been backed up to #{backup_path.bold.green}\n"
          end
        end
      end

      # @param <String> *args — list of arguments or a single string
      def run_system_command(*args)
        cmd = args.join(' ')
        raise 'No command to run was given' unless cmd

        info("\n" + cmd.green) if Arli.debug?
        o, e, s = Open3.capture3(cmd)
        info("\n" + o) if Arli.debug? && o
        info("\n" + e.red) if e && Arli.debug?
        [o, e, s]
      rescue Exception => e
        error "Error running [#{args.join(' ')}]\n" \
              "Current folder is [#{Dir.pwd.yellow}]", e
        raise e
      end
    end
  end
end
