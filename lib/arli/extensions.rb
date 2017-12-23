class String
  def underscore
    self.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
        gsub(/([a-z\d])([A-Z])/, '\1_\2').
        tr('-', '_').
        downcase
  end

  def reformat_wrapped(width = 70, indent_with = 8)
    ind = (' ' * indent_with)
    (ind + self.gsub(/\s+/, ' ').gsub(/(.{1,#{width}})( |\Z)/, "\\1\n" + ind))
  end

end
