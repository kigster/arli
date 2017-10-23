module Arli
  class Configuration
    attr_accessor :library_index

    def initialize
      self.library_index = LIBRARY_INDEX_JSON_GZ
    end
  end
end
