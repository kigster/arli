require 'spec_helper'

RSpec.describe Arli::CLI do
  subject(:cli) { described_class.new(argv) }

  before do
    allow_any_instance_of(::Arli::CLI).to receive(:execute)
    allow_any_instance_of(::Arli::Commands::Base).to receive(:info)
    allow(described_class).to receive(:info)
  end

  context 'no command or arguments' do
    let(:argv) { %w[] }

    before { cli.parse }

    its(:options) { should be_empty }
    its(:command_name) { should be_nil }
  end

  context 'install command' do
    let(:argv) { %w[install -l tmp -a spec/fixtures/ArliFile-another.yml ] }

    before do
      FileUtils.rm_rf('tmp')
      cli.parse
    end

    its(:command_name) { should eq :install }
    its(:options) { should include(:lib_home) }
  end
end
