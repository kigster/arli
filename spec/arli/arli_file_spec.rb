require 'spec_helper'
require 'yaml'

RSpec.describe Arli::ArliFile do
  let(:file) { 'spec/fixtures/ArliFile.yml' }

  let(:contents) { File.read(file) }
  let(:arli_file_hash) { YAML.load(contents) }

  context 'verify reading from the YAML file' do
    it 'should load dependencies' do
      expect(arli_file_hash['dependencies'].size).to eq 3
      expect(arli_file_hash['version']).to eq '1.0.0'
    end
  end

  context 'ArliFile' do
    subject(:arli_file) { described_class.new(file) }
    its(:first) { should be_kind_of(Arduino::Library::Model)}

    context 'first dependency' do
      subject(:library) { arli_file.first }
      its(:name) { should eq 'ESP8266WiFi' }
      its(:version) { should eq '1.0' }
      its(:url) { should eq 'https://github.com/esp8266/Arduino' }
    end
  end
end
