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

    def info(msg, header = nil)
      printf('%-20s', header.blue) if header
      printf((header ? ' : ' : '') + msg + "\n") if msg
    end

    def debug(msg)
      printf('%-20s', header.blue) if header
      printf((header ? ' : ' : '') + msg + "\n") if msg
    end

    def s(msg, newline = false)
      printf msg + ' ' if msg
      puts if newline
    end

    def print_success
      s '✔ '.bold.green
    end

    def print_failure
      s ' ✖ '.bold.red + "\n"
    end

  end
end
