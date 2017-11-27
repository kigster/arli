require 'bundler/setup'
require 'rspec/its'
require 'simplecov'

SimpleCov.start

require 'arli'
require 'pp'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before do
    Arli.configure do |config|
      config.help    = false
      config.verbose = false
      config.trace   = false
      config.debug   = false
    end
  end

  config.before do
    Arli::Output.disable!
  end

  config.before type: :aruba do
    Arli::Output.enable!
  end
end
