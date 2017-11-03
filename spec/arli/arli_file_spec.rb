require 'spec_helper'
require 'yaml'

RSpec.describe Arli::ArliFile do
  let(:file) { 'ArliFile.yml' }
  let(:path) { 'spec/fixtures/' }
  let(:file_path) { path + file }
  let(:contents) { File.read(file_path) }
  let(:arli_file_hash) { YAML.load(contents) }

  context 'verify reading from the YAML file' do
    it 'should load dependencies' do
      expect(arli_file_hash['dependencies'].size).to eq 3
      expect(arli_file_hash['version']).to eq '1.0.0'
    end
  end

  context 'ArliFile' do
    subject(:arli_file) { described_class.new(file_path) }
    context 'custom filename' do
      its(:first) { should be_kind_of(Arduino::Library::Model)}

      context 'first dependency' do
        subject(:library) { arli_file.first }
        its(:name) { should eq 'ESP8266WiFi' }
        its(:version) { should eq '1.0' }
        its(:url) { should eq 'https://github.com/esp8266/Arduino' }
      end
    end

    context 'default filename' do
      it 'should initialize' do
        Dir.chdir('spec/fixtures') do
          af = described_class.new

          expect(af.libraries.first.name).to eq 'Mooo'
        end
      end
    end
  end
end
