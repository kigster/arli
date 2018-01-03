require 'spec_helper'
require 'yaml'

module Arli
  module Lock
    module Formats
      module Template
        @arlifile = nil
        class << self
          attr_accessor :arlifile, :path, :lib_path
        end

        RSpec.describe CMakeRenderer do
          before(:context) do
            Arli::Helpers::Output.disable!

            @mod          = ::Arli::Lock::Formats::Template
            @mod.path     = 'spec/fixtures/file5'
            @mod.lib_path = './libraries'

            Arli.configure do |config|
              config.arlifile.path        = @mod.path
              config.libraries.path       = @mod.lib_path
              config.arlifile.lock_format = :cmake
              config.runtime.pwd          = Dir.pwd
            end

            FileUtils.rm_rf(@mod.lib_path) if Dir.exist?(@mod.lib_path)

            @mod.arlifile = ::Arli::ArliFile.new(config: Arli.config)
            @mod.arlifile.install
          end

          after(:context) do
            @mod = ::Arli::Lock::Formats::Template
            FileUtils.rm_rf(@mod.lib_path) if Dir.exist?(@mod.lib_path)
          end

          let(:root) { Dir.pwd }
          let(:path) { 'spec/fixtures/file5' }
          let(:config) { Arli.config }
          let(:lib_path) { './libraries' }
          let(:file) { config.arlifile.name }
          let(:file_path) { path + '/' + file }
          let(:contents) { ::File.read(file_path) }
          let(:expected_result) { ::File.read("#{path}/Arlifile-Expected") }
          let(:arlifile_hash) { Hashie::Mash.new(Hashie::Extensions::SymbolizeKeys.symbolize_keys(YAML.load(contents))) }
          let(:arlifile) { ::Arli::Lock::Formats::Template.arlifile }

          context 'verify fixture' do
            subject { arlifile_hash }
            its(:device) { should_not be_nil }
            its(:version) { should eq '2.0.0' }
            its(:libraries_path) { should eq './libraries' }
          end

          context 'create a valid ArliFile instance' do
            it 'should have libraries' do
              expect(arlifile.libraries.size).to eq(4)
              expect(arlifile.libraries.last.canonical_dir).to eq 'EEPROMex'
            end

            it 'should have created a folder' do
              expect(Dir.exist?(lib_path)).to be(true)
            end

            context 'renderer' do
              let(:dependent_lib_name) { 'Adafruit GFX Library' }
              let(:dependent_lib) { renderer.library_by_name(dependent_lib_name) }

              let(:lib_name_with_dependency) { 'Adafruit LED Backpack Library' }
              let(:lib_with_dependency) { renderer.library_by_name(lib_name_with_dependency) }

              subject(:renderer) { described_class.new(arlifile) }

              its(:library_path) { should eq './libraries' }
              its(:arli_library_path) { should eq '${CMAKE_CURRENT_SOURCE_DIR}/libraries' }
              its(:libraries_with_dependencies) { should_not be_empty }

              it 'should find GFX library by name' do
                expect(dependent_lib).to_not be_nil
                expect(dependent_lib.name).to eq(dependent_lib_name)
              end

              it 'should have setup dependencies for a library' do
                expect(renderer.dependencies(lib_with_dependency).size).to eq 1
                expect(renderer.dependencies(lib_with_dependency)).to include(dependent_lib)
              end

              context 'Lock::File' do
                let(:lock_file) { ::Arli::Lock::File.new(config: config, arlifile: arlifile) }
                let(:lock_file_path) { "#{path}/Arlifile.cmake" }

                before do
                  FileUtils.rm_f(lock_file_path)
                  lock_file.lock!(*arlifile.libraries)
                  expect(lock_file.lock_file_path).to eq(lock_file_path)
                  expect(::File.exist?(lock_file_path)).to be(true)
                end

                subject(:lock_file_contents) { ::File.read(lock_file_path) }
                let(:render_result) { renderer.render }

                it { is_expected.to eq(render_result) }
                it { is_expected.to eq(expected_result) }

              end
            end

          end
        end
      end
    end
  end
end
