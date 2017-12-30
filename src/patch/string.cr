class String
  def to_boolean
    case self
    when "true", "YES" then true
    when "false", "NO" then false
    else nil
    end
  end
end

