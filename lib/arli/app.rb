require 'colored2'
require 'optparse'
require 'hashie/mash'
require 'saves/cli/parser'
require 'forwardable'
module Saves
  module CLI
    class App
      extend Forwardable
      def_delegators :@parser, :options, :output

      attr_accessor :args, :command, :parser, :options, :output

      def initialize(args)
        if args.nil? || args.empty?
          self.args = %w[--help]
        else
          self.args = args.dup
        end

        self.parser  = ::Saves::CLI::Parser
        self.options = parser.options
        self.output  = parser.output
      end

      def parse!
        if args.first =~ /^-/
          parser.global.parse!(args)
        else
          cmd = self.args.shift.to_sym
          begin
            Parser.parser_for(cmd).parse!(args)
            self.command = cmd # did not raise exception, so valid command.
          rescue Saves::CLI::InvalidCommandError => e
            options[:errors] = [e.message]
          end
        end
      end

      def out
        output.join("\n")
      end

    end
  end
end
