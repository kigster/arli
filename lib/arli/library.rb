module Arli
  class Library
    attr_accessor :lib

    def initialize(lib)
      self.lib = lib
    end

    def method_missing(method, *args, &block)
      lib.send(method, *args, &block)
    end

  end
end
