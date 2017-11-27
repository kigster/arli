require 'colored2'
require 'tty-cursor'

module Arli
  module Output

    class << self
      attr_accessor :enabled, :cursor
      def enable!
        self.enabled = true
      end
      def enabled?
        self.enabled
      end
      def disable!
        self.enabled = false
      end
    end

    self.enable!
    self.cursor = TTY::Cursor

    def cursor
      Arli::Output.cursor
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
      __pf header.bold.yellow + ': ' if header
      error e.message if (e && e.respond_to?(:message))
      if e && Arli.config.trace
        __pf e.backtrace.reverse.join("\n")
      elsif e
        __pf "\nUse -t (--trace) for detailed exception\n" +
             "or -D (--debug) to print Arli config\n"
      end
    end

    def raise_invalid_arli_command!(cmd, e = nil)
      raise Arli::Errors::InvalidCommandError.new(cmd)
    end

    # Shortcuts disabled in tests
    def ___(msg = nil, newline = false)
      return unless Arli::Output.enabled?
      __pf msg if msg
      __pt if newline
    end

    def __pt(*args)
      puts(*args) if Arli::Output.enabled?
    end

    def __p(*args)
      print(*args) if Arli::Output.enabled?
    end

    def __pf(*args)
      printf(*args) if Arli::Output.enabled?
    end

    def ok
      ___ '.'.green
    end

    def check
      ___ '✔'.green
    end

    def fuck
      ___ '✖'.red
    end

    def header(command: nil)
      out = "\n#{hr}\n"
      out << "Arli (#{::Arli::VERSION.yellow})"
      out << " running command #{command.name.to_s.magenta.bold}" if command
      out << " for #{command.params.to_s.blue}\n" if command
      out << "Library Path: #{Arli.default_library_path.green}\n"
      out << "#{hr}\n"
      info out
    end

    def hr
      ('-' * (ENV['COLUMNS'] || 80)).red.dark
    end

  end
end
