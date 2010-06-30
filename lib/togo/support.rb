class String

  def titleize
    self.gsub(/\b\w/){$&.upcase}
  end

  def humanize
    self.tr('_',' ')
  end

end
