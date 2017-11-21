require 'spec_helper'
require 'yaml'

RSpec.describe Arli::Commands::Install, with_local_index: true do

  before do
    allow_any_instance_of(::Arli::CLI).to receive(:header)
    allow_any_instance_of(::Arli::Installer).to receive(:s)
    allow_any_instance_of(::Arli::Commands::Base).to receive(:info)
    allow_any_instance_of(::Arli::Commands::Install).to receive(:debug)
    allow(described_class).to receive(:info)
  end

  context 'install command' do
    let(:argv) { %w[install -l tmp -p spec/fixtures/file3 ] }
    subject(:cli) { Arli::CLI.new(argv) }

    before do
      FileUtils.rm_rf('tmp')
      cli.parse
    end

    its(:command) { should be_kind_of(Arli::Commands::Install) }
    # its(:options) { should include(:lib_home) }
  end
end

