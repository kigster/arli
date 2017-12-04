require 'aruba_helper'

RSpec.describe 'install', :type => :aruba do
  let(:command) { "exe/arli #{args} -C " }
  let(:output) { last_command_started.stdout.chomp }

  let(:root_dir) { Dir.pwd }
  let(:lib_dir) { root_dir + '/tmp/libraries' }
  let(:lib_args) { " '#{lib_identifier}' -v -t " }
  let(:args) { "install #{lib_args} -l #{lib_dir}" }

  before do
    FileUtils.rm_rf(lib_dir)
    expect(Dir.exist?(lib_dir)).to be(false)
    run_simple command
  end

  context 'install by library name' do
    let(:lib_identifier) { 'Adafruit GFX Library' }
    let(:lib_actual) { 'Adafruit_GFX' }

    it 'should install this one library' do
      expect(output).to match(/#{lib_actual}/)
      expect(Dir.exist?(lib_dir)).to be(true)
      expect(Dir.exist?("#{lib_dir}/#{lib_actual}")).to be(true)
    end
  end

  context 'install by file or URL' do
    let(:lib_identifier) { 'https://github.com/jfturcot/SimpleTimer' }
    let(:lib_actual) { 'SimpleTimer' }

    it 'should install this one library' do
      expect(output).to match(/#{lib_actual}/)
      expect(Dir.exist?(lib_dir)).to be(true)
      expect(Dir.exist?("#{lib_dir}/#{lib_actual}")).to be(true)
    end
  end
end
