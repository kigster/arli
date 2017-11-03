require 'spec_helper'

RSpec.describe Arli::File::Finder do
  let(:finder) { described_class }

  context '#verify_arli_file' do
    let(:file) { 'spec/fixtures/Arlifile' }
    subject(:af) { Arli::ArliFile.new(finder.verify_arli_file(file) ) }
    its(:size) { should eq 1 }
  end

  context '#default_arli_file' do
    let(:file) { 'Arlifile' }
    it 'should blow up when file is not in the current directory' do
      expect { finder.default_arli_file }.to raise_error(::Arli::Errors::ArliFileNotFound)
    end

    context 'in the right directory' do
      it 'should create ArliFile' do
        Dir.chdir('spec/fixtures') do
          expect(finder.default_arli_file).to eq file
        end
      end
    end
  end
end
