module M3U8
  # ByteRange represents sub range of a resource
  class ByteRange
    include Concern

    property length : Int32?
    property start : Int32?

    # ```
    # ByteRange.parse(ByteRange.new(length: 4500, start: 600))
    # ByteRange.parse({ length: 4500, start: 600 })
    # ByteRange.parse("4500@600")
    # ByteRange.parse
    # ```
    def self.parse(item = nil)
      case item
      when String then new(item)
      when NamedTuple then new(item)
      when ByteRange then item
      else new
      end
    end

    # ```
    # ByteRange.new("4500@600")
    # ByteRange.new("4500")
    # ```
    def self.new(string : String)
      return new if string.empty?

      values = string.split('@').map &.to_i
      new(values[0]?, values[1]?)
    end

    # ```
    # options = { length: 4500, start: 600 }
    # ByteRange.new(options)
    # ByteRange.new(length: 4500, start: 600)
    # ```
    def self.new(params : NamedTuple = NamedTuple.new)
      new(
        length: params[:length]?,
        start: params[:start]?,
      )
    end

    # ```
    # ByteRange.new
    # ```
    def initialize(@length = nil, @start = nil)
    end

    # ```
    # byterange = ByteRange.new
    # byterange.empty? # => true
    # byterange = ByteRange.new(length: 0)
    # byterange.empty? # => true
    # byterange.length = 4500
    # byterange.empty? # => false
    # ```
    def empty?
      length = @length
      length.nil? || length.zero?
    end

    # ```
    # byterange = ByteRange.new(length: 4500, start: 600)
    # byterange.to_s # => "4500@600"
    # byterange = ByteRange.new(length: 4500)
    # byterange.to_s # => "4500"
    # byterange = ByteRange.new
    # byterange.to_s # => ""
    # ```
    def to_s
      attributes.join('@')
    end

    # ```
    # left = ByteRange.new(length: 4500, start: 600)
    # right = "4500@600",
    # left == right # => true
    # ```
    def == (other : String)
      to_s == other
    end

    # ```
    # left = ByteRange.new(length: 4500, start: 600)
    # right = { length: 4500, start: 600 },
    # left == right # => true
    # ```
    def == (other : NamedTuple)
      to_s == ByteRange.new(other).to_s
    end

    # ```
    # left =  ByteRange.new(length: 4500, start: 600),
    # right =  ByteRange.new(length: 4500, start: 600)
    # left == right # => true
    # ```
    def == (other : ByteRange)
      to_s == other.to_s
    end

    private def attributes
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

