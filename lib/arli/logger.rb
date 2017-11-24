require 'colored2'

module Arli
  module Logger
    def self.included(base)
      base.instance_eval do
        %i(debug info error warn fatal).each do |level|
          define_method "_#{level}" do |*args|
            Arli.logger.send(level, *args) if Arli.logger
          end
        end
      end
    end
  end
end
