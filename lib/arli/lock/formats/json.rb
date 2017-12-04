require_relative 'base'

module Arli
  module Lock
    module Formats
      class Json < Base
        attr_accessor :hash

        def header
          self.hash = {}
          nil
        end

        def format(library)
          hash[library.canonical_dir] = library.to_hash
          nil
        end

        def footer
          JSON.pretty_generate(hash)
        end
      end
    end
  end
end
