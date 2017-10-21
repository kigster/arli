require 'spec_helper'

RSpec.describe Arli::CLI do
  subject(:cli) { described_class.new(argv) }

  before do
    allow_any_instance_of(::Arli::Commands::Base).to receive(:execute)
    allow_any_instance_of(::Arli::Commands::Base).to receive(:info)
    allow(described_class).to receive(:output)
  end

  context 'no command or arguments' do
    let(:argv) { %w[] }

    before { cli.parse }

    its(:options) { should be_empty }
    its(:command) { should be_nil }
  end

  context 'install command' do
    let(:argv) { %w[install -l tmp -j spec/fixtures/arli.json -u ] }

    before do
      FileUtils.rm_rf('tmp')
      cli.parse
    end

    its(:command) { should eq :install }
    its(:options) { should include(:lib_home) }
    its(:options) { should include(:update_if_exists) }
  end
end
