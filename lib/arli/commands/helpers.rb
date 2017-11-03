module Arli
  module Commands
    module Helpers
      def header
        out = "——————————————————————————————————————————————————————————\n"
        out << "Arli           : Version #{::Arli::VERSION.bold.yellow}\n"
        out << "Command        : #{command.to_s.bold.blue}\n" if command
        out << "Library Path   : #{lib_path.bold.green}\n" if lib_path
        out << "ArliFile       : #{arli_file.file.bold.magenta}\n" if arli_file && arli_file.file
        out << '——————————————————————————————————————————————————————————'

        info out
      end
    end
  end
end
