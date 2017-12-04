require_relative 'base'

module Arli
  module Lock
    module Formats
      class Text < Base
        def format(library)
          "#{library.canonical_dir},#{library.version},#{library.path}"
        end
      end
    end
  end
end
