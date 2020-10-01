class String
  def remove_fancy_chars
    gsub(/[^[:word:][:space:][:punct:]]/, '').strip
  end
end
