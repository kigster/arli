require 'spec_helper'

RSpec.describe Arli::Configuration do

  describe '#library_index' do
    it 'default value is ' do
      expect(Arli::Configuration.new.library_index).to eq 'http://downloads.arduino.cc/libraries/library_index.json.gz'
    end
  end
end
