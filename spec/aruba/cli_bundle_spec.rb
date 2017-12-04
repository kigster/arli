require 'aruba_helper'

RSpec.describe 'bundle', :type => :aruba do
  let(:command) { "exe/arli #{args} -C " }
  let(:output) { last_command_started.stdout.chomp }

  context 'bundle file3/Arlifile' do
    let(:root_dir) { Dir.pwd }
    let(:lib_dir) { root_dir + '/tmp/libraries' }
    let(:args) { "bundle -a #{root_dir}/spec/fixtures/file3 -l #{lib_dir}" }

    before do
      FileUtils.rm_rf(lib_dir)
      expect(Dir.exist?(lib_dir)).to be(false)
      run_simple command
      expect(Dir.pwd).to end_with('arli')
    end

    it 'should bundle libraries' do
      expect(output).to match(/Adafruit/)
      expect(Dir.exist?(lib_dir)).to be(true)
      expect(Dir.exist?("#{lib_dir}/Time")).to be(true)
      expect(Dir.exist?("#{lib_dir}/Adafruit_GFX")).to be(true)
      expect(Dir.exist?("#{lib_dir}/Adafruit_Sensor")).to be(true)
    end
  end

  context 'fail gracefully when a library is missing' do
    let(:root_dir) { Dir.pwd }
    let(:lib_dir) { root_dir + '/tmp/libraries' }
    let(:args) { "bundle -a #{root_dir}/spec/fixtures/file4  -l #{lib_dir}" }

    before do
      FileUtils.rm_rf(lib_dir)
      run_simple command
    end

    it 'should show an error libraries' do
      expect(Dir.exist?(lib_dir)).to be(true)
      expect(Dir.exist?("#{lib_dir}/Adafruit_Sensor")).to be(false)
      expect(output).to match(/Error:/)
    end
  end
end
