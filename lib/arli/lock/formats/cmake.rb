require_relative 'base'

module Arli
  module Lock
    module Formats
      class Cmake < Base

        def header
          "# vi:syntax=cmake\n" +
          "set(ARLI_LIBRARIES)"
        end

        def format(library)
          "# Library #{library.name}, version #{library.version}, url: #{library.url}\n" +
              "prepend(ARDUINO_ARLI_LIBS ${ARDUINO_ARLI_LIBS} #{library.canonical_dir})"
        end

        def footer
          "set(ARLI_LIBRARIES $ARLI_LIBRARIES PARENT_SCOPE)"
        end
      end
    end
  end
end
