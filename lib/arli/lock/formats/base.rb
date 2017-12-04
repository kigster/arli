
module Arli
  module Lock
    module Formats
      class Base
        attr_accessor :lock_file

        def initialize(lock_file)
          self.lock_file = lock_file
        end

        # Optional header
        def header
        end

        def format(library)
          raise Arli::Errors::AbstractMethodCalled, "#format on Base"
        end

        # Optional footer
        def footer
        end
      end
    end
  end
end
