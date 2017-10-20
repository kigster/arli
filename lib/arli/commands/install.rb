#!/usr/bin/env ruby
require 'rubygems'

unless defined?(Colored2)
  class String
    def noop
      self
    end
    %i(clear dark black yellow red blue green bold italic cyan on).each do |m|
      alias_method m, :noop;
    end
  end
end

class GemLoader
  TRIES = 2
  attr_accessor :gem_name
  def initialize(gem_name)
    self.gem_name = gem_name
  end
  def load &block
    begin
      tries ||= TRIES
      printf 'Loading '.bold.blue
      printf '%12.12s...'.bold.yellow, gem_name
      require gem_name
      printf "OK\n".bold.green
    rescue Exception
      if tries == TRIES
        printf "MISSING\n".bold.red
        printf 'Installing '.bold
        printf '%9.9s...'.bold.yellow, gem_name
        %x(gem install #{gem_name})
        printf "HIFIVE!\n".bold.green
        Gem.clear_paths
        tries -= 1
        retry
      end
    end
  end
end

%w(colored2).each do |gem|
  GemLoader.new(gem).load
end

require 'json'
require 'fileutils'
require 'open3'

class Installer
  attr_accessor :arduino_custom_lib_path
  def initialize(lib_path)
    @arduino_custom_lib_path = lib_path
  end

  def setup
    FileUtils.mkdir_p(arduino_custom_lib_path)
    yield self if block_given?
    self
  end

  def install
    libs = JSON.load(File.read('ArduinoLibraries.json'))
    puts "Installing into #{arduino_custom_lib_path.bold.green}"
    Dir.chdir(arduino_custom_lib_path) do
      libs["dependencies"].each do |dependency|
        name = dependency["name"]
        url = dependency["git"]
        printf "processing library: " + name.yellow.bold + "\n"
        unless Dir.exist?(name)
          cmd = "git clone -v #{url} #{name} 2>&1"
        else
          cmd = "cd #{name} && git pull --rebase 2>&1"
        end
        puts "command: " + cmd.bold.blue
        o, e, s = Open3.capture3(cmd)
        puts o if o
        puts e.red if e
      end
    end
  end
end

@installer = Installer.new(
   ARGV.first ||
   ENV["ARDUINO_CUSTOM_LIBRARY_PATH"] ||
  (ENV['HOME'] + "/Documents/Arduino/libraries"))

@installer.setup.install
