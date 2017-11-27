require_relative 'installer'

module Arli
  class Library
    attr_accessor :lib, :config, :canonical_dir

    def initialize(lib, config: Arli.config)
      self.lib           = lib
      self.config        = config
    end

    def install
      Arli::Installer.new(self).install
    end

    def rm_rf!
      FileUtils.rm_rf(dir)
    end

    def libraries_home
      config.libraries.path
    end

    def dir
      lib.name.gsub(/ /, '_')
    end

    def path
      libraries_home + '/' + dir
    end

    def canonical_path
      libraries_home + '/' + canonical_dir
    end

    def exists?
      Dir.exist?(path)
    end

    def method_missing(method, *args, &block)
      if lib && lib.respond_to?(method)
        lib.send(method, *args, &block)
      else
        super(method, *args, &block)
      end
    end

  end
end
