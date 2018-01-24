module M3U8
  # ByteRange represents sub range of a resource
  class ByteRange
    include Concern

    property length : Int32?
    property start : Int32?

    def self.new(string : String)
      return new if string.empty?

      values = string.split('@').map &.to_i
      new(values[0]?, values[1]?)
    end

    def self.new(params : NamedTuple = NamedTuple.new)
      new(
        length: params[:length]?,
        start: params[:start]?,
      )
    end

    def initialize(@length = nil, @start = nil)
    end

    def empty?
      length = @length
      length.nil? || length.zero?
    end

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

