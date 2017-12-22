require 'aruba_helper'

RSpec.describe 'command search', :type => :aruba do
  let(:command) {"exe/arli #{args} -Cm 0"}
  let(:output) {last_command_started.stdout.chomp}

  let(:root_dir) {Dir.pwd}
  let(:args) {"search '#{lib_identifier}'"}

  before {run_simple command}

  context 'search by name' do
    let(:lib_identifier) {'^Adafruit GFX Library'}
    it 'find multiple versions, but one lib' do
      expect(output).to match(/#{lib_identifier}/)
      expect(output).to match(/Libraries : 1/)
    end
  end

  context 'search by regex' do
    let(:lib_identifier) {'name: /adafruit/i'}
    before do
      include 'arduino/library/include'
      @results = search(name: /adafruit/i)
      expect(@results).to_not be_empty
    end

    it 'find multiple versions' do
      expect(@results).to_not be_empty
      expect(@results.size).to be > 100
      expect(output).to match(/Versions : #{@results.size}/)
    end
  end
end
