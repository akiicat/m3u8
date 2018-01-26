struct Time
  def iso8601(count = 0)
    format = (millisecond == 0) ? "%FT%TZ" : "%FT%T.%LZ"
    to_s(format)
  end

  def self.iso8601(time : String)
    begin
      parse(time, "%FT%T.%L%z").to_utc
    rescue
      parse(time, "%FT%T%z").to_utc
    end
  end
end
