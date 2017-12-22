require 'aruba_helper'

RSpec.describe 'command bundle', :type => :aruba do
  let(:command) {"exe/arli #{args} -C "}
  let(:output) {last_command_started.stdout.chomp}

  context 'successful installations' do
    let(:root_dir) {Dir.pwd}
    let(:lib_dir) {root_dir + '/tmp/libraries'}

    before do
      FileUtils.rm_rf(lib_dir)
      expect(Dir.exist?(lib_dir)).to be(false)
      run_simple command
      expect(Dir.pwd).to end_with('arli')
    end

    context 'Arlifile from spec/fixtures/file3' do
      let(:args) {"bundle -a #{arlifile_path} -l #{lib_dir} -f cmake"}
      let(:arlifile_path) {"#{root_dir}/spec/fixtures/file3"}

      it 'should bundle libraries' do
        expect(output).to match(/Adafruit/)
        expect(Dir.exist?(lib_dir)).to be(true)
        expect(Dir.exist?("#{lib_dir}/Time")).to be(true)
        expect(Dir.exist?("#{lib_dir}/Adafruit_GFX")).to be(true)
        expect(Dir.exist?("#{lib_dir}/Adafruit_Sensor")).to be(true)
        expect(File.exist?(arlifile_path + "/Arlifile.cmake"))
      end
    end

    context 'Arlifile from spec/fixtures/file2' do
      let(:args) {"bundle -a #{arlifile_path} -l #{lib_dir}"}
      let(:arlifile_path) {"#{root_dir}/spec/fixtures/file2"}

      it 'should bundle libraries' do
        expect(output).to match(/RF24/)
        expect(output).to match(/DS1307RTC/)
        expect(Dir.exist?(lib_dir)).to be(true)
        expect(Dir.exist?("#{lib_dir}/DS1307RTC")).to be(true)
        expect(Dir.exist?("#{lib_dir}/RF24")).to be(true)
        expect(Dir.exist?("#{lib_dir}/Adafruit_Sensor")).to be(false)
        expect(File.exist?(arlifile_path + "/Arlifile.txt"))
      end
    end

  end

  context 'fail gracefully when a library is missing' do
    let(:root_dir) {Dir.pwd}
    let(:lib_dir) {root_dir + '/tmp/libraries'}
    let(:arlifile_path) {"#{root_dir}/spec/fixtures/file4"}
    let(:args) {"bundle -a #{arlifile_path} -l #{lib_dir} -f cmake"}

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
