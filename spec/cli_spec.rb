require 'spec_helper'

RSpec.describe Arli::CLI do
  subject(:cli) { described_class.new(argv) }

  context 'no command or arguments' do
    let(:argv) { %w[] }

    before { cli.parse }

    its(:options) { should be_empty }
    its(:command) { should be_nil }
  end

  context 'install command' do
    let(:argv) { %w[install -L tmp  -a spec/fixtures/arli.json ] }

    before do
      allow_any_instance_of(::Arli::Commands::Install).to receive(:install_library)
      cli.parse
    end

    its(:command) { should eq :install }
  end
end
