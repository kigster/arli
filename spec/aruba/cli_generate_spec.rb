require 'aruba_helper'

RSpec.describe 'command generate', :type => :aruba do
  let(:command) { "exe/arli #{args} -C " }
  let(:output) { last_command_started.stdout.chomp }

  context 'successful generation' do
    let(:root_dir) { Dir.pwd }
    let(:project_name) { 'SensorClock' }
    let(:src_dir) { root_dir + '/tmp/projects' }
    let(:project_path) { "#{src_dir}/#{project_name}" }

    before do
      FileUtils.rm_rf(src_dir)
      expect(Dir.exist?(project_path)).to be(false)
      run_simple command
    end

    context 'creates a CMAKE project' do
      let(:args) { "generate #{project_name} -w #{src_dir}" }

      it 'should generate libraries' do
        expect(output).to match(/#{project_name}/)

        expect(Dir.exist?(src_dir)).to be(true)
        expect(Dir.exist?(project_path)).to be(true)
        expect(Dir.exist?("#{project_path}/cmake")).to be(true)

        expect(File.exist?("#{project_path}/src/Arlifile")).to be(true)
        expect(File.exist?("#{project_path}/src/CMakeLists.txt")).to be(true)
        expect(File.exist?("#{project_path}/src/#{project_name}.cpp")).to be(true)
      end
    end
  end
end
