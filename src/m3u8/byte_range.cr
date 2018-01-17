module M3U8
  # ByteRange represents sub range of a resource
  class ByteRange
    property length : Int32
    property start : Int32?

    def self.new(string : String)
      return new(0, nil) if string.empty?

      values = string.split('@').map &.to_i
      new(values[0], values[1]?)
    end

    def self.new(params : NamedTuple = NamedTuple.new)
      length, start = params[:length]? || 0, params[:start]?
      new(length, start)
    end

    def initialize(@length = 0, @start = nil)
    end

    def empty?
      @length.zero?
    end

    def to_s
      return "" if empty?
      attributes.join('@')
    end

    def attributes
      [
        length_format,
        start_format
      ].compact
    end

    private def length_format
      "#{length}"
    end

    private def start_format
      "#{start}" unless start.nil?
    end
  end
end
pp M3U8::ByteRange.new ""
