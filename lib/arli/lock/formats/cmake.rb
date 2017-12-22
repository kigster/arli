require_relative 'base'

module Arli
  module Lock
    module Formats
      class Cmake < Base
        extension :cmake

        attr_accessor :comments

        def initialize(*args)
          super(*args)
          @comments = ''
        end

        def header
          "# vi:syntax=cmake\n" + 'set(ARLI_LIBRARIES)'
        end

        def format(library)
          self.comments << "# #{library.canonical_dir}:\n#     name: #{library.name}\n#  version: #{library.version}\n#      url: #{library.url}\n#\n"
          "prepend(ARDUINO_ARLI_LIBS ${ARDUINO_ARLI_LIBS} #{library.canonical_dir})"
        end

        def footer
          'set(ARLI_LIBRARIES $ARLI_LIBRARIES PARENT_SCOPE)' + "\n\n" + comments
        end
      end
    end
  end
end
