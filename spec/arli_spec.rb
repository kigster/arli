require 'spec_helper'

RSpec.describe Arli do
  it 'has a version number' do
    expect(Arli::VERSION).not_to be nil
  end

  subject { Arli.config }

  before do
    Arli.configure do |c|
      c.debug = false
      c.verbose = false
      c.trace = false
    end
  end

  its(:debug) { should be_falsey }
  its(:verbose) { should be_falsey }
  its(:trace) { should be_falsey }
end
