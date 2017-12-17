struct Bool
  def to_yes_no
    self == true ? "YES" : "NO"
  end
end

