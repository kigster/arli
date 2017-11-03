require 'spec_helper'

RSpec.describe Arli::Config do
  let(:config) { described_class.config }

  before do
    Arli.configure do |config|
      config.library.path = '/tmp'
      config.arlifile.name = 'MooFile'
    end
  end

  context 'library' do
    subject { config.library }
    its(:path) { should eq '/tmp' }
    its(:index_url) { should eq ::Arduino::Library::DefaultDatabase.library_index_url }
  end

  context 'arlifile' do
    subject { config.arlifile}
    its(:name) { should eq 'MooFile' }
    its(:candidates) { should include 'ArliFile.yaml' }
  end
end
