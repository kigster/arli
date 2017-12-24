require 'spec_helper'
require 'yaml'

RSpec.describe Arli::ArliFile do
  let(:file) { Arli.config.arlifile.name }
  let(:path) { 'spec/fixtures/file1' }
  let(:file_path) { path + '/' + file }
  let(:contents) { File.read(file_path) }
  let(:arlifile_hash) { Hashie::Mash.new(YAML.load(contents)) }

  context 'verify reading from the YAML file' do
    subject { arlifile_hash }
    it 'should load dependencies' do
      expect(arlifile_hash.dependencies.size).to eq 2
    end

    its(:version) { should  eq '1.0.1' }
    its(:libraries_path) { should eq './libraries'}
    its(:lock_format) { should eq 'cmake'}
  end

  context 'ArliFile' do
    before { Arli.configure { |config| config.arlifile.path = path } }

    subject(:arli_file) { described_class.new(config: Arli.config) }

    context 'custom filename' do
      let(:path) { 'spec/fixtures/file1' }
      its(:first) { should be_kind_of(Arli::Library::SingleVersion) }
      context 'first dependency' do
        subject(:library) { arli_file.first }
        its(:name) { should eq 'NTPClient' }
        its(:version) { should eq '3.1.0' }
        its(:url) { should eq 'http://downloads.arduino.cc/libraries/github.com/arduino-libraries/NTPClient-3.1.0.zip' }
      end
    end

    context 'with CMAKE device info' do
      let(:path) { 'spec/fixtures/file5' }
      it 'should initialize' do
        expect(arli_file.first.name).to eq 'Adafruit LED Backpack Library'
      end
      its(:arlifile_hash) { should_not be_nil }

      context 'device info' do
        subject(:device) { arlifile_hash.device }
        its(:board) { should eq 'nano' }
        its(:cpu) { should eq 'atmega328p' }
        its(:libraries) { should include(:hardware) }
        it 'should have hardware and software libs' do
          expect(device.libraries.hardware.size).to eq 2
          expect(device.libraries.arduino.size).to eq 1
        end
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
