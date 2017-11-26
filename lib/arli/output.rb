require 'colored2'

module Arli
  module Output

    def error(msg, exception = nil)
      printf 'Runtime Error: '.red + "\n#{msg}\n" if msg
      if exception
        puts
        printf 'Exception: '.red + "\n#{exception.inspect.red}\n\n"
      end
      puts
    end

    def raise_invalid_arli_command!(cmd, e = nil)
      report_exception(e) if e
      raise Arli::Errors::InvalidCommandError,
            "Error: #{cmd ? cmd.to_s.red : 'nil'} is not a " +
                'valid arli command_name!'
    end

    def report_exception(e, header = nil)
      error header.bold.yellow if header
      printf ' ✖ '.bold.red
      error e.message if e && e.respond_to?(:message)
      raise e if e && Arli.config.trace
    end

    def info(msg, header = nil)
      printf('%-20s', header.blue) if header
      printf((header ? ' : ' : '') + msg + "\n") if msg
    end

    def debug(msg)
      printf('%-20s', header.blue) if header
      printf((header ? ' : ' : '') + msg + "\n") if msg
    end

    def ___(msg, newline = false)
      printf msg + ' ' if msg
      puts if newline
    end

    def print_success
      ____ '✔ '.bold.green
    end

    def print_failure
      ____ ' ✖ '.bold.red + "\n"
    end

    def header(command: nil)
      out = "\n#{hr}\n"
      out << "Arli (#{::Arli::VERSION.yellow})"
      out << " running #{command.name.to_s.blue}" if command
      out << " for #{command.params.to_s.blue}\n" if command
      out << "\n"
      out << "Library Path: #{Arli.default_library_path.green}\n"
      out << "\n#{hr}\n"
      info out
    end

    def hr
      '——————————————————————————————————————————————————————————'.cyan
    end

  end
end
