require 'aruba_helper'

RSpec.describe 'arli executable', :type => :aruba do

  let(:command) { "exe/arli #{args}" }
  let(:output) { last_command_started.stdout.chomp }

  context 'simple commands' do
    before { run_simple command }

    context 'help' do
      let(:args) { '-h' }
      it 'should print help' do
        expect(output).to match(/Arli/)
      end
    end

    context 'search help' do
      let(:args) { 'search -h' }
      it 'should print search helps' do
        expect(output).to match(/name-match/)
      end
    end
  end

  context 'search install file3' do
    let(:root_dir) { Dir.pwd  }
    let(:lib_dir) { root_dir + '/tmp/libraries' }
    let(:args) { "install -a #{root_dir}/spec/fixtures/file3 -l #{lib_dir}" }

    before do
      FileUtils.rm_rf(lib_dir)
      expect(Dir.exist?(lib_dir)).to be(false)
      run_simple command
      expect(Dir.pwd).to end_with('arli')
    end

    it 'should install libraries' do
      expect(output).to match(/Adafruit/)
      expect(Dir.exist?(lib_dir)).to be(true)
      expect(Dir.exist?("#{lib_dir}/Time")).to be(true)
      expect(Dir.exist?("#{lib_dir}/Adafruit_GFX")).to be(true)
    end
  end
end
