module Arli
  module Errors
    class ArliError < StandardError; end

    class InvalidCommandError < ArliError; end

    class ArliFileNotFound < ArliError; end
  end
end
