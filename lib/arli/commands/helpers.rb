module Arli
  module Commands
    module Helpers
      def header
        out = "——————————————————————————————————————————————————————————\n"
        out << "Arli           : Version #{::Arli::VERSION.yellow}\n"
        out << "Command        : #{command.to_s.blue}\n" if command
        out << "Library Path   : #{lib_path.green}\n" if lib_path
        out << '——————————————————————————————————————————————————————————'
        info out
      end
    end
  end
end
