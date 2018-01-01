module M3U8
  # ByteRange represents sub range of a resource
  class ByteRange
    property length : Int32
    property start : Int32?

    def self.new(params : NamedTuple = NamedTuple.new)
      new(
        length: params[:length],
        start: params[:start]?
      )
    end

    def initialize(@length, @start = nil)
    end

    # def self.parse(text)
    #   values = text.split('@').map &.to_i
    #   ByteRange.new(length: values[0], start: values[1]?)
    # end

    def to_s
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
