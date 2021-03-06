require 'colored2'
require 'tty-cursor'

module Arli
  module Helpers
    module Output
      CHAR_FAILURE = '✖'.red
      CHAR_SUCCESS = '✔'.green

      # Singleton Class
      class << self
        attr_accessor :enabled, :cursor

        def enable!
          self.enabled = true
        end

        def enabled?
          enabled
        end

        def disable!
          self.enabled = false
        end
      end

      # Include Module

      enable!
      self.cursor = TTY::Cursor

      def cursor
        Arli::Helpers::Output.cursor
      end

      def info(msg, header = nil)
        __pf('%-20s', header.blue) if header
        __pf((header ? ' : ' : '') + msg + "\n") if msg
      end

      def debug(msg)
        __pf('%-20s', header.blue) if header
        __pf((header ? ' : ' : '') + msg + "\n") if msg
      end

      def error(msg, exception = nil)
        __pf "#{msg.to_s.red}\n" if msg
        __pf "#{exception.inspect.red}\n\n" if exception
      end

      def report_exception(e, header = nil)
        if header
          __pf header.bold.yellow + ': '
        else
          __pf 'Error: '.bold.red
        end
        error e.message if e&.respond_to?(:message)
        if e && Arli.config.trace
          __pf "\n"
          __pf 'Top 10 stack trace'.bold.yellow + "\n"
          __pf e.backtrace.reverse[-10..-1].join("\n").red + "\n"
        elsif e
          __pf "\nUse -t (--trace) for detailed exception\n" \
               "or -D (--debug) to print Arli config\n"
        end
        raise(e)
      end

      def raise_invalid_arli_command!(cmd, _e = nil)
        raise Arli::Errors::InvalidCommandError, cmd
      end

      # Shortcuts disabled in tests
      def ___(msg = nil, newline = false)
        return unless Arli::Helpers::Output.enabled?

        __pf msg if msg
        __pt if newline
      end

      def __pt(*args)
        puts(*args) if Arli::Helpers::Output.enabled?
      end

      def __p(*args)
        print(*args) if Arli::Helpers::Output.enabled?
      end

      def __pf(*args)
        printf(*args) if Arli::Helpers::Output.enabled?
      end

      def print_target_dir(d, verb = 'installed')
        print_action_success(d.green, "#{verb} #{d.green} ")
      end

      def print_action_starting(action_name)
        if verbose?
          indent_cursor
          ___ "⇨  #{action_name.yellow} ... "
        end
        if block_given?
          yield
          ok if verbose?
        end
      end

      def print_action_success(short, verbose = nil)
        if verbose? && !quiet?
          indent_cursor
          ___ "⇨  #{verbose || short} #{CHAR_SUCCESS}"
        elsif !quiet?
          ___ "#{short} #{CHAR_SUCCESS} "
        end
      end

      def print_action_failure(short, verbose = nil)
        if verbose? && !quiet?
          indent_cursor
          ___ "⇨  #{verbose || short} #{CHAR_FAILURE}\n"
        elsif !quiet?
          ___ "#{short} #{CHAR_FAILURE} "
        end
      end

      def action_fail(action, exception)
        print_action_failure(action.class.short_name,
                             "#{action.class.short_name} failed with #{exception.message.red}\n" \
                                 "Action Description: #{action.class.description}")
        raise(exception)
      end

      def action_ok(action)
        print_action_success(action.action_name)
      end

      def ok
        ___ " #{CHAR_SUCCESS} "
      end

      def fuck
        ___ " #{CHAR_FAILURE} "
      end

      def header(command: nil)
        out = "#{hr}\n"
        out << 'Arli '.bold.red + "(#{::Arli::VERSION.yellow})"
        out << ", executing command #{command.name.to_s.blue.bold}" if command
        if command&.params && Arli.config.verbose
          out << "\n#{command.params.to_s.bold.magenta}\n"
        end
        out << command.additional_info if command.respond_to?(:additional_info)
        out << "Library Path: #{Arli.default_library_path.bold.green}\n"
        out << hr.to_s
        info out
      end

      def hr
        ('—' * ((ENV['COLUMNS'] || 70).to_i - 1)).bold.black
      end

      # Some shortcuts
      def verbose?
        config.verbose && !quiet?
      end

      def quiet?
        config.quiet
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

      def debug?
        config.debug
      end

      def indent_cursor(value = 40)
        ___ cursor.column(value)
      end
    end
  end
end
