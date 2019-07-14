# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Arli::CLI::App do
  subject(:app) { described_class.new(argv) }

  context 'no command or arguments' do
    let(:argv) { %w[] }
    before { app.parse_global_flags }
    its(:argv) { should eq [] }
    its(:command) { should be_nil }
  end

  context 'with global flags' do
    before { expect(Arli::CLI::ParserFactory).to receive(:print_parser_help) }
    let(:argv) { %w[-v -t install] }
    before { app.parse_global_flags }
    its(:argv) { should eq %w(install) }
    it 'should set config' do
      expect(Arli.config.verbose).to be_truthy
      expect(Arli.config.trace).to be_truthy
    end
  end

  context 'help' do
    let(:argv) { %w[-h] }

    before do
      allow_any_instance_of(Arli::CLI::Parser).to receive(:print)
      app.start
    end

    it 'should have help set' do
      expect(Arli.config.help).to be_truthy
    end

    context 'command help' do
      let(:argv) { %w[search -h] }
      it 'should have help set' do
        expect(Arli.config.help).to be_truthy
      end
    end
  end

  context 'bundle command' do
    let(:lib_dir) { './tmp' }
    let(:argv) { %W[bundle -l #{lib_dir} -a spec/fixtures/file3] }

    subject(:app) { described_class.new(argv) }

    before do
      Arli.config.help = false
      FileUtils.rm_rf(lib_dir)
      expect(Dir.exist?(lib_dir)).to be_falsey
      app.start
    end

    it 'should create library folder' do
      expect(Arli.config.libraries.path).to eq(lib_dir)
      expect(Dir.exist?(lib_dir)).to be_truthy
      expect(app.command.name).to eq :bundle
    end
  end
end
