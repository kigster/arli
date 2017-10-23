require 'spec_helper'

RSpec.describe Arli do
  it 'has a version number' do
    expect(Arli::VERSION).not_to be nil
  end

  subject { Arli }

  its(:logger) { should be_kind_of(Logger) }
  it 'should have :debug method' do
    Arli.debug('hello')
  end


end
