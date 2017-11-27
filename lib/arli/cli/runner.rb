require 'colored2'
require 'arli/cli/app'
require 'pp'
module Arli
  module CLI
    # For the reasons this file is the way it is, please refer to
    # https://github.com/erikhuda/thor/wiki/Integrating-with-Aruba-In-Process-Runs
    class Runner
      def initialize(argv, stdin = STDIN, stdout = STDOUT, stderr = STDERR, kernel = Kernel)
        @argv, @stdin, @stdout, @stderr, @kernel = argv, stdin, stdout, stderr, kernel
      end

      def execute!
        exit_code = begin
          $stderr = @stderr
          $stdin  = @stdin
          $stdout = @stdout

          Arli::CLI::App.new(@argv).start
          0
        rescue StandardError => e
          b = e.backtrace
          @stderr.puts("#{b.shift.bold}:\n")
          @stderr.puts("#{e.message.bold.red} (#{e.class.name.yellow})")
          @stderr.puts(b.map { |s| "\tfrom #{s}" }.join("\n")).red
          1
        rescue SystemExit => e
          e.status
        ensure
          $stderr = STDERR
          $stdin  = STDIN
          $stdout = STDOUT
          ap(Arli.config.to_hash, indent: 6, index: false) if Arli.config.debug
        end
        @kernel.exit(exit_code)
      end
    end
  end

end
