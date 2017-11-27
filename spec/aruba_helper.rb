require 'spec_helper'
require 'aruba/rspec'
require 'aruba/in_process'
require 'arli/cli/runner'

RSpec.configure do |config|
  config.include Aruba::Api
end

Aruba.configure do |config|
  config.command_launcher = :in_process
  config.main_class = Arli::CLI::Runner
end
