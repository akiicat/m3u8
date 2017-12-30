class String::Builder
  def puts(io)
    self << io + "\n"
  end
end

