require 'spec_helper'
require 'yaml'

module Arli
  module Lock
    module Formats
      module Template

        RSpec.describe CMakeRenderer do

          let(:root) { Dir.pwd }
          let(:path) { 'spec/fixtures/file5' }

          before do
            Arli.configure do |config|
              config.arlifile.path        = path
              config.arlifile.lock_format = :cmake
              config.runtime.pwd          = Dir.pwd
            end
          end

          let(:config) { Arli.config }
          let(:lib_path) { './libraries' }
          let(:file) { config.arlifile.name }
          let(:file_path) { path + '/' + file }
          let(:contents) { ::File.read(file_path) }
          let(:expected_result) { ::File.read("#{path}/Arlifile-Expected") }
          let(:arlifile_hash) { Hashie::Mash.new(Hashie::Extensions::SymbolizeKeys.symbolize_keys(YAML.load(contents))) }

          context 'verify fixture' do
            subject { arlifile_hash }
            its(:device) { should_not be_nil }
            its(:version) { should eq '2.0.0' }
            its(:libraries_path) { should eq lib_path }
          end

          context 'create a valid ArliFile instance' do
            let(:arlifile) { ::Arli::ArliFile.new(config: config) }
            before { arlifile.install }

            it 'should have libraries' do
              expect(arlifile.libraries.size).to eq(4)
              expect(arlifile.libraries.last.canonical_dir).to eq 'EEPROMex'
            end

            it 'should have created a folder' do
              expect(Dir.exist?(lib_path)).to be(true)
            end

            after { FileUtils.rm_rf(lib_path) }

            context 'renderer' do
              subject(:renderer) { described_class.new(arlifile) }

              its(:library_path) { should eq './libraries' }
              its(:arli_library_path) { should eq '${CMAKE_CURRENT_SOURCE_DIR}/libraries' }

              context 'Lock::File' do
                let(:lock_file) { ::Arli::Lock::File.new(config: config, arlifile: arlifile) }
                let(:lock_file_path) { "#{path}/Arlifile.cmake" }

                before do
                  FileUtils.rm_f(lock_file_path)
                  lock_file.lock!(*arlifile.libraries)
                  expect(lock_file.lock_file_path).to eq(lock_file_path)
                  expect(::File.exist?(lock_file_path)).to be(true)
                end

                let(:lock_file_contents) { ::File.read(lock_file_path) }
                let(:render_result) { renderer.render }

                it 'cmake file should be the same as the render result' do
                  expect(lock_file_contents).to eq(render_result)
                end

                it 'cmake file should be the same expected fixture' do
                  expect(lock_file_contents).to eq(expected_result)
                end

              end
            end

          end
        end
      end
    end
  end
end
