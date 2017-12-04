require 'aruba_helper'

RSpec.describe 'search', :type => :aruba do
  let(:command) { "exe/arli #{args} -C " }
  let(:output) { last_command_started.stdout.chomp }

  let(:root_dir) { Dir.pwd }
  let(:args) { "search '#{lib_identifier}'" }
  let(:lib_identifier) { '^Adafruit GFX Library' }

  before do
    run_simple command
  end

  context 'by name' do
    it 'find multiple versions' do
      expect(output).to match(/#{lib_identifier}/)
      expect(output).to match(/Libraries : 1/)
    end
  end
end
