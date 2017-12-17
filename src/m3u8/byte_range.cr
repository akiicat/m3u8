module M3U8
  # ByteRange represents sub range of a resource
  class ByteRange
    property length : Int32
    property start : Int32?

    def initialize(params)
      @length = params[:length]
      @start = params[:start]?
    end

    # def self.parse(text)
    #   values = text.split('@').map &.to_i
    #   ByteRange.new(length: values[0], start: values[1]?)
    # end

    def to_s
      formatted_attributes.join('@')
    end

    def formatted_attributes
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
