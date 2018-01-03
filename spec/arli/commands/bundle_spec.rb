require 'spec_helper'
require 'yaml'

RSpec.describe Arli::Commands::Bundle, with_local_index: true do

  context 'bundle command' do
    let(:argv) { %w[bundle -t -l tmp -a spec/fixtures/file3 ] }
    subject(:app) { Arli::CLI::App.new(argv) }

    before do
      Arli::Helpers::Output.disable!
      FileUtils.rm_rf('tmp')
      app.start
    end

    its(:command) { should be_kind_of(Arli::Commands::Bundle) }
  end
end

