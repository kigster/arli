# frozen_string_literal: true

require 'erb'
require 'forwardable'

module Arli
  module Lock
    module Formats
      module Template
        class CMakeRenderer
          extend Forwardable

          def_delegators :@arlifile, :config, :arlifile_hash, :libraries

          class << self
            attr_accessor :template
          end

          self.template = ::File.read(::File.expand_path('../Arlifile.cmake.erb', __FILE__))

          attr_accessor :arlifile, :erb

          def initialize(arlifile)
            self.arlifile = arlifile
            self.erb      = ERB.new(self.class.template)
          end

          def render
            erb.result(binding)
          end

          alias output render

          def device
            arlifile_hash.device
          end

          def board
            device&.board ? device.board : 'uno'
          end

          def cpu
            device&.cpu ? device.cpu : 'atmega328p'
          end

          def hardware_libraries
            device&.libraries ? device.libraries.hardware || [] : []
          end

          def arduino_libraries
            device&.libraries ? device.libraries.arduino || [] : []
          end

          def device_libraries
            Array(hardware_libraries + arduino_libraries).flatten
          end

          def custom_libraries_headers_only
            libraries.select(&:headers_only) || []
          end

          def device_libraries_headers_only
            device_libraries.select(&:headers_only) || []
          end

          def library_path
            config.libraries.path
          end

          def libraries_with_dependencies
            libraries.select(&:depends)
          end

          def library_by_name(name)
            libraries.find { |l| l.name.downcase == name.downcase }
          end

          def dependencies(lib)
            return nil unless lib.depends

            lib.depends.map { |name| library_by_name(name) }
          end

          def cmake_dependencies(lib)
            return nil unless lib.depends

            "set(#{lib.canonical_dir}_DEPENDS_ON_LIBS #{dependencies(lib).map(&:canonical_dir).join(' ')})"
          end

          def arli_library_path
            if library_path.start_with?('/')
              library_path.to_s
            elsif library_path.start_with?('~')
              "$ENV{HOME}#{library_path[1..-1]}"
            elsif library_path.start_with?('./')
              "${CMAKE_CURRENT_SOURCE_DIR}/#{library_path[2..-1]}"
            elsif library_path && !library_path.empty?
              library_path
            else
              '${CMAKE_CURRENT_SOURCE_DIR}/libraries'
            end
          end
        end
      end
    end
  end
end
