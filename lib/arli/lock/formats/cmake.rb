# frozen_string_literal: true

require_relative 'base'
require_relative 'template/cmake_renderer'

module Arli
  module Lock
    module Formats
      class Cmake < Base
        extension :cmake

        attr_accessor :libraries

        def initialize(*args)
          super(*args)
          self.libraries = []
        end

        def format(library)
          libraries << library
          nil
        end

        def footer
          renderer = Template::CMakeRenderer.new(arlifile)
          renderer.render
        end
      end
    end
  end
end
