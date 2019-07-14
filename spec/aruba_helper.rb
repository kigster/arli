# frozen_string_literal: true

require 'spec_helper'
require 'aruba/rspec'
require 'aruba/processes/in_process'
require 'arli/cli/runner'

RSpec.configure do |config|
  config.include Aruba::Api
end

# Some state gets fucked, and tests fail when run this way.

Aruba.configure do |config|
  config.command_launcher = :in_process
  config.main_class       = Arli::CLI::Runner
end
