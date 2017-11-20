module Arli
  class Config
    DEFAULT_FILENAME = 'Arlifile'.freeze
    PARAMS           = %i(
                          library_path
                          library_index_path
                          library_index_url
                          logger
                          debug
                          )

    class << self
      attr_accessor *PARAMS
    end
  end
end
