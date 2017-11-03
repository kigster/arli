require 'arli/arli_file'
require 'arli/errors'

module Arli
  module File
    module Finder
      class << self
        def verify_arli_file(file)
          raise(Arli::Errors::ArliFileNotFound,
                'Arlifile could not be found') unless file && ::File.exist?(file)
          file
        end

        def default_arli_file(custom_path = nil)
          file = check_candidate_files(custom_path)

          raise(::Arli::Errors::ArliFileNotFound,
                'Arlifile could not be found') unless file && ::File.exist?(file)

          file
        end

        private

        def check_candidate_files(custom_path = nil)
          candidates(custom_path).find { |f| ::File.exist?(f) }
        end

        def candidates(custom_path = nil)
          path = custom_path ? custom_path + '/' : ''
          Arli.config.arlifile.candidates.map { |f| "#{path}#{f}" }
        end
      end
    end
  end
end

