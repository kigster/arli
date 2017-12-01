require 'spec_helper'
require 'yaml'

RSpec.describe Arli::ArliFile do
  let(:file) { Arli.config.bundle.arlifile.name }
  let(:path) { 'spec/fixtures/file1' }
  let(:file_path) { path + '/' + file }
  let(:contents) { File.read(file_path) }
  let(:arli_file_hash) { YAML.load(contents) }

  context 'verify reading from the YAML file' do
    it 'should load dependencies' do
      expect(arli_file_hash['dependencies'].size).to eq 3
      expect(arli_file_hash['version']).to eq '1.0.0'
    end
  end

  context 'ArliFile' do
    before { Arli.configure { |config| config.bundle.arlifile.path = path } }

    subject(:arli_file) { described_class.new(config: Arli.config) }

    context 'custom filename' do
      its(:first) { should be_kind_of(Arli::Library) }
      context 'first dependency' do
        subject(:library) { arli_file.first }
        its(:name) { should eq 'ESP8266WiFi' }
        its(:version) { should eq '1.0' }
        its(:url) { should eq 'https://github.com/esp8266/Arduino' }
      end
    end

    context 'default filename' do
      let(:path) { 'spec/fixtures/file2' }
      it 'should initialize' do
        expect(arli_file.first.name).to eq 'DS1307RTC'
        expect(arli_file.map(&:name)).to include('DS1307RTC')
      end
    end
  end
end
