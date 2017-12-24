require 'arli/helpers/inherited'

module Arli
  module Lock
    module Formats
      class Base
        include Arli::Helpers::Inherited
        attr_assignable :extension

        attr_accessor :lock_file, :arlifile

        def initialize(lock_file)
          self.lock_file = lock_file
          self.arlifile = lock_file.arlifile
        end

        # Optional header
        def header
        end

        def format(library)
        end

        # Optional footer
        def footer
        end

        def extension
          self.class.extension
        end
      end
    end
  end
end
