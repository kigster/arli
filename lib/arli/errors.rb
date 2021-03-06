# frozen_string_literal: true

module Arli
  module Errors
    class ArliError < StandardError; end

    class InvalidCommandError < ArliError; end

    class InvalidSyntaxError  < ArliError; end

    class InvalidSearchSyntaxError < InvalidSyntaxError; end

    class InvalidInstallSyntaxError < InvalidSyntaxError; end

    class AbstractMethodCalled < ArliError; end

    class ArliFileNotFound < ArliError; end

    class LibraryAlreadyExists < ArliError; end

    class LibraryNotFound < ArliError; end

    class InstallerError < ArliError; end

    class TooManyMatchesError < ArliError; end

    class ZipFileError < InstallerError; end

    class RequiredArgumentsMissing < ArliError; end

  end
end
