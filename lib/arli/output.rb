require 'colored2'

module Arli
  module Output

    class << self
      attr_accessor :enabled
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
      ap Arli.config.to_hash if Arli.config.debug and Arli::Output.enabled?
    end

    def report_exception(e, header = nil)
      __pf header.bold.yellow + ': ' if header
      error e.message if (e && e.respond_to?(:message))
      __pf e.backtrace.reverse.join("\n") if (e && Arli.config.trace)
    end

    def raise_invalid_arli_command!(cmd, e = nil)
      report_exception(e) if e
      raise Arli::Errors::InvalidCommandError,
            "#{cmd ? cmd.to_s.bold.red.bold : 'nil'}"
    end

    # Shortcuts disabled in tests
    def ___(msg = nil, newline = false)
      return unless Arli::Output.enabled?
      __pf msg if msg
      __p '.'.green if msg.nil?
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
      ___ '.'.bold.green
    end

    def fuck
      ___ '✖'.bold.red
    end

    def header(command: nil)
      out = "\n#{hr}\n"
      out << "Arli (#{::Arli::VERSION.yellow})"
      out << " running #{command.name.to_s.magenta.bold}" if command
      out << " for #{command.params.to_s.blue}\n" if command
      out << "Library Path: #{Arli.default_library_path.green}\n"
      out << "#{hr}\n"
      info out
    end

    def hr
      '——————————————————————————————————————————————————————————'.red
    end

  end
end
