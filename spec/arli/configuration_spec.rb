require 'spec_helper'

RSpec.describe Arli::Configuration do
  subject(:config) { described_class.config }

  before do
    described_class.configure do |config|
      config.libraries.path = '/tmp'
      config.bundle.arlifile.path  = '/tmp'
      config.if_exists.overwrite = true
    end
  end

  context 'arlifile' do
    its(:debug) { should be_falsey }

    it 'should still correctly setup index_url' do
      expect(config.database.url).to eq ::Arduino::Library::DefaultDatabase.library_index_url
    end

    it 'should have set the overwrite' do
      expect(config.if_exists.overwrite).to be_truthy
      expect(config.if_exists.backup).to be_falsey
      expect(config.if_exists.abort).to be_falsey
    end
  end

  context 'search command' do
    it 'should still correctly setup index_url' do
      expect(config.search.results.limit).to eq 100
    end
  end
end

