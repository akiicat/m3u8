module M3U8
  # ByteRange represents sub range of a resource
  class ByteRange
    property length : Int32
    property start : Int32?

    def initialize(**params)
      @length = params[:length]
      @start = params[:start]?
    end

    def initialize(params)
      @length = params[:length]
      @start = params[:start]?
    end

    def self.parse(text)
      values = text.split('@').map &.to_i
      ByteRange.new(length: values[0], start: values[1]?)
    end

    def to_s
      "#{length}#{start_format}"
    end

    private def start_format
      return if start.nil?
      "@#{start}"
    end
  end
end
