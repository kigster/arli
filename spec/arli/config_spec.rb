require 'spec_helper'

RSpec.describe Arli::Config do
  let(:config) { described_class }

  before do
    Arli.configure do |config|
      config.library_path = '/tmp'
    end
  end

  context 'library' do
    subject { config }
    its(:library_path) { should eq '/tmp' }
    its(:debug) { should be_falsey }
    its(:library_index_url) { should eq ::Arduino::Library::DefaultDatabase.library_index_url }
    its(:library_index_path) { should eq ::Arduino::Library::DefaultDatabase.library_index_path }
  end
end
