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
            device && device.board ? device.board : 'uno'
          end

          def cpu
            device && device.cpu ? device.cpu : 'at'
          end

          def hardware_libraries
            device && device.libraries ? device.libraries.hardware : []
          end

          def arduino_libraries
            device && device.libraries ? device.libraries.arduino : []
          end

          def device_libraries
            Array(hardware_libraries + arduino_libraries).flatten
          end

          def device_libraries_headers_only
            device_libraries.select { |l| l.headers_only }
          end

          def library_path
            config.libraries.path
          end

          def arli_library_path
            if library_path.start_with?('/')
              "#{library_path}"
            elsif library_path.start_with?('~')
              "$ENV{HOME}#{library_path[1..-1]}"
            elsif library_path.start_with?('./')
              "${CMAKE_CURRENT_SOURCE_DIR}/#{library_path[2..-1]}"
            elsif library_path && library_path.size > 0
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
