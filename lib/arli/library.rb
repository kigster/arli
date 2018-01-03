require_relative 'library/single_version'
require_relative 'library/multi_version'
require 'arduino/library/model'
require 'arli/errors'

module Arli
  module Library
    ADDITIONAL_KEYS = %i(depends headers_only)

    def library_model(lib)
      return lib if lib.is_a?(::Arduino::Library::Model)
      ::Arduino::Library::Model.from(lib).tap do |model|
        if model.nil?
          lib_output = (lib && lib['name']) ? lib['name'] : lib.to_s
          raise Arli::Errors::LibraryNotFound, 'Error: '.bold.red +
              "Library #{lib_output.yellow} ".red + "was not found.\n\n".red +
              %Q[  HINT: run #{"arli search 'name: /#{lib_output}/'".green}\n] +
              %Q[        to find the exact name of the library you are trying\n] +
              %Q[        to install. Alternatively, provide a url: field.\n]
        end
      end
    end

    def make_lib(lib)
      additional_keys = {}
      ADDITIONAL_KEYS.each do |k|
        if lib.is_a?(Hash) && lib[k]
          additional_keys[k] = lib[k]
          lib.delete(k)
        end
      end

      ::Arli::Library::SingleVersion.new(library_model(lib)).tap do |svlib|
        additional_keys.each_pair do |key, value|
          svlib.send("#{key}=", value)
        end
      end
    end
  end
end

