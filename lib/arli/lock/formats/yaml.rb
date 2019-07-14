# frozen_string_literal: true

require_relative 'json'
require 'yaml'
module Arli
  module Lock
    module Formats
      class Yaml < Json
        extension :yml

        def footer
          "# vi:syntax=yaml\n" +
            YAML.dump(hash)
        end
      end
    end
  end
end
