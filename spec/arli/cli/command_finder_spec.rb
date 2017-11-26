require 'spec_helper'

RSpec.describe Arli::CLI::CommandFinder do

  subject(:finder) { described_class.new(argv) }
  let(:config) { Arli.config }

  context 'no command or arguments' do
    let(:argv) { %w[] }
    its(:detect_command) { should be_nil }
  end

  context 'install command' do
    let(:argv) { %w[install -l /tmp -a spec/fixtures/file2 ] }
    its(:detect_command) { should eq :install }

    context 'command' do
      before { finder.parse! }
      subject(:command) { finder.command }

      it { is_expected.to be_kind_of(Arli::Commands::Install) }

      it 'should have changed the library path' do
        expect(config.arlifile.path).to eq('spec/fixtures/file2')
        expect(config.libraries.path).to eq('/tmp')
      end
    end
  end
end
