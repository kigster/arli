require 'spec_helper'

RSpec.describe Arli::CLI do
  let(:argv) { %w[] }
  subject(:cli) { described_class.new(argv) }

  before { cli.parse }

  its(:options) { should be_empty }
  its(:command) { should be_nil  }

  context 'help command' do
    let(:argv) { %w[install] }
    its(:command) { should eq :install}
  end

end
