require_relative 'json'
require 'yaml'
module Arli
  module Lock
    module Formats
      class Yaml < Json
        extension :yml

        def footer
          "# vi:syntax=yaml\n" +
          YAML.dump(unique_libraries)
        end
      end
    end
  end
end
