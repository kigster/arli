# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Arli::CLI::CommandFinder do
  subject(:finder) { described_class.new(argv) }
  let(:config) { Arli.config }

  before {
    Arli.config.libraries.temp_dir = Dir.mktmpdir
    Arli.config.runtime.argv = argv
  }

  context 'no command or arguments' do
    let(:argv) { %w[] }
    its(:detect_command) { should be_nil }
  end

  context 'bundle command' do
    let(:argv) { %w[bundle -l /tmp -a spec/fixtures/file2] }
    its(:detect_command) { should eq :bundle }

    context 'command' do
      before { finder.parse! }
      subject(:command) { finder.command }

      it { is_expected.to be_kind_of(Arli::Commands::Bundle) }

      it 'should have changed the library path' do
        expect(config.arlifile.path).to eq('spec/fixtures/file2')
        expect(config.libraries.path).to eq('/tmp')
      end

      context 'aliases' do
        context 'search (s)' do
          let(:argv) { %w[s /adafruit/] }
          it { is_expected.to be_kind_of(Arli::Commands::Search) }
        end

        context 'generate (gen)' do
          let(:argv) { %w[g Moo] }
          it { is_expected.to be_kind_of(Arli::Commands::Generate) }
        end
      end
    end
  end
end
